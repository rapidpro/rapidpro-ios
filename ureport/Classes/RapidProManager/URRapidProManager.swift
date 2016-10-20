//
//  URRapidProManager.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

protocol URRapidProManagerDelegate {
    func newMessageReceived(_ message:String)
}

class URRapidProManager: NSObject {
    
    var delegate:URRapidProManagerDelegate?
    static var sendingAnswers:Bool = false
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "rapidpro"
    }
    
    func getPollMessage() {
        
        var userKey = URUser.activeUser()!.key
        userKey = userKey?.replacingOccurrences(of: "-", with: "", options: [], range: nil)
        userKey = userKey?.replacingOccurrences(of: ":", with: "", options: [], range: nil)
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URRapidProManager.path())
            .child(byAppendingPath: "message")
            .child(byAppendingPath: userKey)
            .queryLimited(toLast: 1)
            .observe(FEventType.childAdded, with: { (snapshot) in
                
                print(snapshot?.value)
                
                if let delegate = self.delegate {
                    delegate.newMessageReceived((snapshot?.value as! NSDictionary).object(forKey: "text") as! String)
                }
            })
    }
    
    
    
    class func sendPollResponse(_ text:String!) {
        
        let pollResponse = URPollResponse(channel: URCountryProgramManager.getChannelOfCurrentCountryProgram(), from:URUser.activeUser()!.key, text: text)
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URRapidProManager.path())
            .child(byAppendingPath: "response")
            .childByAutoId()
            .setValue(pollResponse.toDictionary(), withCompletionBlock: { (error:Error?, firebase:Firebase?) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }else if !(firebase!.key.isEmpty) {
                    print("poll message sent")
                }
                
            })
    }
    
    class func getFlowDefinition(_ flowUuid: String, completion:@escaping (URFlowDefinition) -> Void) {
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
        ]
        
        let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI)flow_definition.json?uuid=\(flowUuid)"
        
        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers).responseObject(completionHandler: { (response:Response<URFlowDefinition,NSError>) -> Void in
            if let flowDefinition = response.result.value {
                completion(flowDefinition)
            }
        })
    }
    
    class func getFlowRuns(_ contact: URContact, completion:@escaping ([URFlowRun]?) -> Void) {
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
        ]
        
        let afterDate = URDateUtil.dateFormatterRapidPro(getMinimumDate())
        let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI)runs.json?contact=\(contact.uuid!)&after=\(afterDate)"
        
        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers).responseObject(completionHandler:{ (response:Response<URAPIResponse<URFlowRun,NSError>, NSError>) -> Void in
            if let response = response.result.value {
                if response.results.count > 0 {
                    completion(response.results)
                }else{
                    completion(nil)
                }
            }else{
                completion(nil)
            }
        })
    }
    
    class func getMinimumDate() -> Date {
        let date = URDateUtil.currentDate()
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var offsetComponents = DateComponents();
        offsetComponents.month = -1;
        
        return (gregorian as NSCalendar).date(byAdding: offsetComponents, to: date as Date, options: [])!;
        
    }
    
    class func getContact(_ user:URUser, completion:@escaping (URContact) -> Void) {
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
        ]
        
        let userId = "ext:" + URUserManager.formatExtUserId(user.key)
        let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI)contacts.json?urns=\(userId)"
        
//        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers).responseJSON{ (_, _, JSON) -> Void in
//            
//            if !JSON.isFailure {
//                
//                let response = JSON.value as! NSDictionary
//                if let results = response.objectForKey("results") as? [NSDictionary] {
//                    for object in results {
//                        let contact = URContact(jsonDict: object)
//                        completion(contact)
//                    }
//                }
//            }
//            
//        }
        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers).responseJSON { (response:Response<AnyObject,NSError>) in
            if let response = response.result.value as? NSDictionary {
                if let results = response.objectForKey("results") as? [NSDictionary] {
                    for object in results {
                        let contact = URContact(jsonDict: object)
                        completion(contact)
                    }
                }
            }
        }
    }
    
    class func sendRulesetResponses(_ user:URUser, responses:[URRulesetResponse], completion:@escaping () -> Void) {
        let token = URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
        let channel = URCountryProgramManager.getChannelOfCurrentCountryProgram()
        
        let userId = URUserManager.formatExtUserId(user.key)
        let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI)external/received/\(channel)/"
        
        let group = DispatchGroup();
        let queue = DispatchQueue(label: "in.ureport-poll-responses", attributes: []);
        
        self.sendingAnswers = true
        
        for response in responses {
            queue.async(group: group, execute: { () -> Void in
                let request = NSMutableURLRequest(url: URL(string: url)!)
                request.httpMethod = "POST"
                request.setValue(token, forHTTPHeaderField: "Authorization")
                request.timeoutInterval = 15
                
                let postString = "from=\(userId)&text=\(response.response)"
                request.httpBody = postString.data(using: String.Encoding.utf8)
                var httpResponse: URLResponse?
                
                do {
                    try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &httpResponse)
                    print("Sent: \(response.response!)")
                } catch {
                    print("Error on sending poll response")
                }
                
                Thread.sleep(forTimeInterval: 2)
            })
        }
        
        group.notify(queue: queue) { () -> Void in
            self.sendingAnswers = false
            completion()
        }
    }
    
    class func sendReceivedMessage(_ user:URUser, text:String) {
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
        ]
        
        let channel = URCountryProgramManager.getChannelOfCurrentCountryProgram()
        
        let userId = URUserManager.formatExtUserId(user.key)
        let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI)external/received/\(channel)/"
        
        let parameters = [
            "from": userId,
            "text": text
        ]
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .URLEncodedInURL, headers: headers).response
    }
    
    class func getContactFields(_ country:URCountry, completion:@escaping ([String]) -> Void) {
        
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.getCountryProgramByCountry(country))!
        ]
        
        Alamofire.request(.GET, "\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI)fields.json", parameters: nil, encoding: .JSON, headers: headers).responseJSON { (response:Response<AnyObject, NSError>) in
         
            if let response = response.result.value as? NSDictionary {
                var arrayFields:[String] = []
                if let results = response.objectForKey("results") as? [NSDictionary] {

                    for dictionary in results {
                        arrayFields.append(dictionary.objectForKey("key") as! String)
                    }

                    completion(arrayFields)
                }else {
                    completion(arrayFields)
                }
                
            }
            
        }
        
    }
    
    class func getStatesByCountry(_ country:URCountry, completion:@escaping (_ states:[URState]?,_ districts:[URDistrict]?) -> Void) {
        
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.getCountryProgramByCountry(country))!
        ]        
        
        Alamofire.request(.GET, "\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI)boundaries.json?aliases=true", parameters: nil, encoding: .JSON, headers: headers).responseJSON { (response: Response<AnyObject, NSError>) in
            
            if let response = response.result.value as? NSDictionary {
                
                var states:[URState] = []
                var districts:[URDistrict] = []

                if let results = response.objectForKey("results") as? [NSDictionary] {

                    if results.isEmpty {
                        completion(states: nil,districts:nil)
                        return
                    }

                    for dictionary in results {

                        let level = dictionary.objectForKey("level") as! Int
                        let name = dictionary.objectForKey("name") as! String

                        switch level {
                        case 0:
                            break
                        case 1:
                            let state = URState(name: name, boundary: dictionary.objectForKey("boundary") as? String)
                            states.append(state)
                            break
                        case 2:
                            let district = URDistrict(name: name, parent: dictionary.objectForKey("parent") as! String)
                            districts.append(district)
                            break
                        default:
                            break
                        }
                        
                    }
                    
                    completion(states: states,districts:districts)
                    
                }else {
                    completion(states: nil,districts:nil)
                }
                
            }
            
        }
        
    }
    
    class func saveUser(_ user:URUser,country:URCountry,setupGroups:Bool,completion:@escaping (_ response:NSDictionary?) -> Void) {
        
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.getCountryProgramByCountry(country))!
        ]
        
        URRapidProContactUtil.buildRapidProUserRootDictionary(user, setupGroups: setupGroups) { (rootDicionary) in
            
            print("===============")
            print(rootDicionary.copy())
            print("\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI)contacts.json")
            print(headers)
            print("===============")
                        
            Alamofire.request(.POST, "\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI)contacts.json", parameters: rootDicionary.copy() as? [String : AnyObject] , encoding: .JSON, headers: headers).responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                
                if response.result.isFailure {
                    print("error \(response.result.value)")
                    completion(response: nil)
                }
                
                if let response = response.result.value as? NSDictionary {
                    completion(response: response)
                }
                
            })
            
        }
    }
    
}

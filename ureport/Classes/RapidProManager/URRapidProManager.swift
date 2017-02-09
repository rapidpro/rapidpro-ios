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
        
        let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)flow_definition.json?uuid=\(flowUuid)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject(completionHandler: { (response:DataResponse<URFlowDefinition>) -> Void in
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
        let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)runs.json?contact=\(contact.uuid!)&after=\(afterDate)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseArray(queue: nil, keyPath: "results", context: nil, completionHandler: { (response:DataResponse<[URFlowRun]>) in
            if let response = response.result.value {
                if response.count > 0 {
                    completion(response)
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
        let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)contacts.json?urns=\(userId)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
            if let response = response.result.value as? NSDictionary {
                if let results = response.object(forKey: "results") as? [NSDictionary] {
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
        let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)external/received/\(channel)/"
        
        let group = DispatchGroup();
        let queue = DispatchQueue(label: "in.ureport-poll-responses", attributes: []);
        
        self.sendingAnswers = true
        
        for response in responses {
            queue.async(group: group, execute: { () -> Void in
                let request = NSMutableURLRequest(url: URL(string: url)!)
                request.httpMethod = "POST"
                request.setValue(token, forHTTPHeaderField: "Authorization")
                request.timeoutInterval = 15
                
                let postString = "from=\(userId)&text=\(response.response!)"
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
        let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)external/received/\(channel)/"
        
        let parameters = [
            "from": userId,
            "text": text
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }
    
    class func getContactFields(_ country:URCountry, completion:@escaping ([String]) -> Void) {
        
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.getCountryProgramByCountry(country))!
        ]        
        
        Alamofire.request("\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI!)fields.json", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
         
            if let response = response.result.value as? NSDictionary {
                var arrayFields:[String] = []
                if let results = response["results"] as? [NSDictionary] {

                    for dictionary in results {
                        arrayFields.append(dictionary.object(forKey:"key") as! String)
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
        
        Alamofire.request("\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI!)boundaries.json?aliases=true", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response: DataResponse<Any>) in
            
            if let response = response.result.value as? NSDictionary {
                
                var states:[URState] = []
                var districts:[URDistrict] = []

                if let results = response.object(forKey:"results") as? [NSDictionary] {

                    if results.isEmpty {
                        completion(nil,nil)
                        return
                    }

                    for dictionary in results {

                        let level = dictionary.object(forKey: "level") as! Int
                        let name = dictionary.object(forKey: "name") as! String

                        switch level {
                        case 0:
                            break
                        case 1:
                            let state = URState(name: name, boundary: dictionary.object(forKey: "boundary") as? String)
                            states.append(state)
                            break
                        case 2:
                            let district = URDistrict(name: name, parent: dictionary.object(forKey: "parent") as! String)
                            districts.append(district)
                            break
                        default:
                            break
                        }
                        
                    }
                    
                    completion(states,districts)
                    
                }else {
                    completion(nil,nil)
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
            print("\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI!)contacts.json")
            print(headers)
            print("===============")
                        
            Alamofire.request("\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI!)contacts.json", method: .post, parameters: rootDicionary.copy() as? [String : AnyObject] , encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response: DataResponse<Any>) in
                
                if response.result.isFailure {
                    print("error \(response.result.value)")
                    completion(nil)
                }
                
                if let response = response.result.value as? NSDictionary {
                    completion(response)
                }
                
            })
            
        }
    }
    
}

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
    func newMessageReceived(message:String)
}

class URRapidProManager: NSObject {
 
    var delegate:URRapidProManagerDelegate?
    static let rapidProUser = NSMutableDictionary()
    
    static let GROUP_UREPORT_YOUTH = "UReport Youth"
    static let GROUP_UREPORT_ADULTS = "UReport Adults"
    static let GROUP_UREPORT_MALES = "UReport Males"
    static let GROUP_UREPORT_FEMALES = "UReport Females"
    static let GROUP_UREPORT_APP = "App U-Reporters"
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "rapidpro"
    }
    
    func getPollMessage() {
        
        var userKey = URUser.activeUser()!.key
        userKey = userKey?.stringByReplacingOccurrencesOfString("-", withString: "", options: [], range: nil)
        userKey = userKey?.stringByReplacingOccurrencesOfString(":", withString: "", options: [], range: nil)
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URRapidProManager.path())
            .childByAppendingPath("message")
            .childByAppendingPath(userKey)
            .queryLimitedToLast(1)
            .observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
                
                print(snapshot.value)
                
                if let delegate = self.delegate {
                    delegate.newMessageReceived((snapshot.value as! NSDictionary).objectForKey("text") as! String)
                }
            })
    }
    
    
 
    class func sendPollResponse(text:String!) {
        
        let pollResponse = URPollResponse(channel: URCountryProgramManager.getChannelOfCurrentCountryProgram(), from:URUser.activeUser()!.key, text: text)
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URRapidProManager.path())
            .childByAppendingPath("response")
            .childByAutoId()
            .setValue(pollResponse.toDictionary(), withCompletionBlock: { (error:NSError!, firebase:Firebase!) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }else if !(firebase!.key.isEmpty) {
                    print("poll message sent")
                }
                
            })
    }
    
    class func getFlowDefinition(flowUuid: String, completion:(URFlowDefinition) -> Void) {
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
        ]
        
        let url = "\(URConstant.RapidPro.API_URL)flow_definition.json?uuid=\(flowUuid)"
        
        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers).responseObject({ (response:URFlowDefinition?, error:ErrorType?) -> Void in
            if let flowDefinition = response {
                completion(flowDefinition)
            }
        })
    }
    
    class func getFlowRuns(contact: URContact, completion:([URFlowRun]) -> Void) {
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
        ]
        
        let afterDate = URDateUtil.dateFormatterRapidPro(getMinimumDate())
        let url = "\(URConstant.RapidPro.API_URL)runs.json?contact=\(contact.uuid!)&after=\(afterDate)"
        
        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers).responseObject({ (response:URAPIResponse<URFlowRun>?, error:ErrorType?) -> Void in
            if let response = response {
                completion(response.results)
            }
        })
    }
    
    class func getMinimumDate() -> NSDate {
        let date = NSDate()
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        let offsetComponents = NSDateComponents();
        offsetComponents.month = -1;
        
        return gregorian!.dateByAddingComponents(offsetComponents, toDate: date, options: [])!;
        
    }
    
    class func getContact(user:URUser, completion:(URContact) -> Void) {
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
        ]
        
        let userId = "ext:" + URUserManager.formatExtUserId(user.key)
        let url = "\(URConstant.RapidPro.API_URL)contacts.json?urns=\(userId)"
        
        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers).responseJSON { (_, _, JSON) -> Void in

                let response = JSON.value as! NSDictionary
                if let results = response.objectForKey("results") as? [NSDictionary] {
                    for object in results {
                        let contact = URContact(jsonDict: object)
                        completion(contact)
                    }
                }
        }
    }
    
    class func sendRulesetResponses(user:URUser, responses:[URRulesetResponse], completion:() -> Void) {
        let token = URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
        let channel = URCountryProgramManager.getChannelOfCurrentCountryProgram()
        
        let userId = URUserManager.formatExtUserId(user.key)
        let url = "\(URConstant.RapidPro.API_URL)external/received/\(channel)/"
        
        let group = dispatch_group_create();
        let queue = dispatch_queue_create("in.ureport-poll-responses", DISPATCH_QUEUE_SERIAL);
        
        for response in responses {
            dispatch_group_async(group, queue, { () -> Void in
                let request = NSMutableURLRequest(URL: NSURL(string: url)!)
                request.HTTPMethod = "POST"
                request.setValue(token, forHTTPHeaderField: "Authorization")
                request.timeoutInterval = 15
                
                let postString = "from=\(userId)&text=\(response.response)"
                request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                var httpResponse: NSURLResponse?
                
                do {
                    try NSURLConnection.sendSynchronousRequest(request, returningResponse: &httpResponse)
                    print("Sent: \(response.response!)")
                } catch {
                    print("Error on sending poll response")
                }
                
                NSThread.sleepForTimeInterval(2)
            })
        }
        
        dispatch_group_notify(group, queue) { () -> Void in
            completion()
        }
    }
    
    class func sendReceivedMessage(user:URUser, text:String) {
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
        ]
        
        let channel = URCountryProgramManager.getChannelOfCurrentCountryProgram()
        
        let userId = URUserManager.formatExtUserId(user.key)
        let url = "\(URConstant.RapidPro.API_URL)external/received/\(channel)/"
        
        let parameters = [
            "from": userId,
            "text": text
        ]

        Alamofire.request(.POST, url, parameters: parameters, encoding: .URLEncodedInURL, headers: headers).response
    }
    
    class func getContactFields(country:URCountry, completion:([String]) -> Void) {
        
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.getCountryProgramByCountry(country))!
        ]
        
        Alamofire.request(.GET, "\(URConstant.RapidPro.API_URL)fields.json", parameters: nil, encoding: .JSON, headers: headers).responseJSON { (_, _, JSON) -> Void in
            
            let response = JSON.value as! NSDictionary
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
    
    class func buildRapidProUserDictionary(user:URUser,country:URCountry,completion:(NSDictionary) -> Void) {
        
        URRapidProManager.getContactFields(country) { (contactFields:[String]) -> Void in
            if !contactFields.isEmpty {
                URRapidProManager.putValueIfExists(user.email, countryProgramContactFields: contactFields, possibleFields: ["email","e_mail"])
                URRapidProManager.putValueIfExists(user.nickname, countryProgramContactFields: contactFields, possibleFields: ["nickname","nick_name"])
                URRapidProManager.putValueIfExists(URDateUtil.birthDayFormatterRapidPro(NSDate(timeIntervalSince1970: NSNumber(double: user.birthday.doubleValue/1000) as NSTimeInterval)), countryProgramContactFields: contactFields, possibleFields: ["birthday","birthdate","birth_day"])
                URRapidProManager.putValueIfExists(String(URDateUtil.getYear(NSDate(timeIntervalSince1970: NSNumber(double: user.birthday.doubleValue/1000) as NSTimeInterval))), countryProgramContactFields: contactFields, possibleFields: ["born"])
                URRapidProManager.putValueIfExists(user.gender, countryProgramContactFields: contactFields, possibleFields: ["gender"])
                URRapidProManager.putValueIfExists(user.state, countryProgramContactFields: contactFields, possibleFields: ["state","region","province","county"])
                URRapidProManager.putValueIfExists(user.district, countryProgramContactFields: contactFields, possibleFields: ["district","lga"])
                URRapidProManager.putValueIfExists(user.country, countryProgramContactFields: contactFields, possibleFields: ["country"])
                completion(URRapidProManager.rapidProUser)
            }
        }
        
    }
    
    class func putValueIfExists(value:String?,countryProgramContactFields:[String],possibleFields:[String]) {
        if value == nil {
            return
        }
        
        for possibleField in possibleFields {
            let index = countryProgramContactFields.indexOf(possibleField)
            if index != nil && index != -1{
                let field = countryProgramContactFields[index!]
                URRapidProManager.rapidProUser.setValue(value, forKey: field)
                break
            }
        }
        
    }
    
    class func getStatesByCountry(country:URCountry, completion:(states:[String]?,districts:[String]?) -> Void) {
        
        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.getCountryProgramByCountry(country))!
        ]
        
        Alamofire.request(.GET, "\(URConstant.RapidPro.API_URL)boundaries.json?aliases=true", parameters: nil, encoding: .JSON, headers: headers).responseJSON { (_, _, JSON) -> Void in
            
            let response = JSON.value as! NSDictionary
            
            var states:[String] = []
            var districts:[String] = []
                        
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
                        states.append(name)
                        break
                    case 2:
                        districts.append(name)
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
    
    class func saveUser(user:URUser,country:URCountry,completion:(response:NSDictionary) -> Void) {

        let headers = [
            "Authorization": URCountryProgramManager.getTokenOfCountryProgram(URCountryProgramManager.getCountryProgramByCountry(country))!
        ]
        
        let rootDictionary = NSMutableDictionary()
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        
        URRapidProManager.rapidProUser.setValue(dateFormat.stringFromDate(NSDate()), forKey: "registration_date")
        rootDictionary.setValue(URRapidProManager.rapidProUser, forKey: "fields")
        rootDictionary.setValue(["ext:\(URUserManager.formatExtUserId(user.key))"], forKey: "urns")
        rootDictionary.setValue(user.nickname, forKey:"name")
        rootDictionary.setValue(["App U-Reporters"], forKey: "groups")
        
        Alamofire.request(.POST, "\(URConstant.RapidPro.API_URL)contacts.json", parameters: rootDictionary.copy() as! [String : AnyObject] , encoding: .JSON, headers: headers).responseJSON { (_, _, JSON) -> Void in
            completion(response: JSON.value as! NSDictionary)
        }
    }
    
}

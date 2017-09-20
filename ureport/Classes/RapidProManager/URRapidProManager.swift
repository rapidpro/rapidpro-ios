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

class URRapidProManager {
    
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
            .child(URRapidProManager.path())
            .child("message")
            .child(userKey!)
            .queryLimited(toLast: 1)
            .observe(.childAdded, with: { snapshot in
                if let value = snapshot.value {
                    print(value)
                }
                if let delegate = self.delegate {
                    delegate.newMessageReceived((snapshot.value as! NSDictionary).object(forKey: "text") as! String)
                }
            })
    }

    class func sendPollResponse(_ text:String!) {
        let pollResponse = URPollResponse(channel: URCountryProgramManager.getChannelOfCurrentCountryProgram(), from:URUser.activeUser()!.key, text: text)

        URFireBaseManager.sharedInstance()
            .child(URRapidProManager.path())
            .child("response")
            .childByAutoId()
            .setValue(pollResponse.toDictionary(), withCompletionBlock: { (error, dbReference) -> Void in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                if !dbReference.key.isEmpty {
                    print("poll message sent")
                }
            })
    }
    
    class func getFlowDefinition(_ flowUuid: String, block:@escaping (URFlowDefinition) -> Void) {
        #if DEBUG
            if let token = URCountryProgramManager.getSandboxToken() {
                let headers = [
                    "Authorization": token
                ]
                let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)v2/definitions.json?flow=\(flowUuid)"
                
                Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {
                    (response) in
                    switch response.result {
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        
                    case .success(let value):
                        if let value = value as? NSDictionary {
                            if let flows = value["flows"] as? [[String: Any]] {
                                if let flowDefinition = URFlowDefinition(JSON: flows[0]) {
                                    block(flowDefinition)
                                }
                            }
                        }
                    }
                })
            }
            
        #else
            URCountryProgramAPI.getCountryProgram(countryCode: URCountryProgramManager.activeCountryProgram()!.code) { countryResponse in
                if let countryResponse = countryResponse {
                    let headers = [
                        "Authorization": countryResponse.token
                    ]
                    let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)v1/flow_definition.json?uuid=\(flowUuid)"
                    
                    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseObject(completionHandler: { (response:DataResponse<URFlowDefinition>) -> Void in
                        if let flowDefinition = response.result.value {
                            completion(flowDefinition)
                        }
                    })
                }
            }
        #endif
    }
    
    class func getFlowRuns(_ contact: URContact, completion:@escaping ([URFlowRun]?) -> Void) {
        #if DEBUG
            if let token = URCountryProgramManager.getSandboxToken() {

                if let contactUuid = contact.uuid {
                    let afterDate = URDateUtil.dateFormatterRapidPro(getMinimumDate())
                    
                    let headers = [
                        "Authorization": token
                    ]
                    
                    let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)v2/runs.json?contact=\(contact.uuid!)&after=\(afterDate)"
                    
                    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {
                        (response) in
                        
                        switch response.result {
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            
                        case .success(let value):
                            if let response = value as? NSDictionary {
                                if let results = response["results"] as? [[String: Any]] {
                                    if results.count > 0 {
                                        completion(results.map{URFlowRun(JSON: $0)!})
                                    } else {
                                        completion(nil)
                                    }
                                } else {
                                    completion(nil)
                                }
                            }
                            
                        }
                    })
                }

            }
            
        #else
            URCountryProgramAPI.getCountryProgram(countryCode: URCountryProgramManager.activeCountryProgram()!.code) { countryResponse in
                if let countryResponse = countryResponse {
                    let headers = [
                        "Authorization": countryResponse.token
                    ]
                    let afterDate = URDateUtil.dateFormatterRapidPro(getMinimumDate())
                    let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)v2/runs.json?contact=\(contact.uuid!)&after=\(afterDate)"
                    
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
            }

        #endif
        }
    
    class func getMinimumDate() -> Date {
        let date = URDateUtil.currentDate()
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var offsetComponents = DateComponents();
        offsetComponents.month = -1;
        
        return (gregorian as NSCalendar).date(byAdding: offsetComponents, to: date as Date, options: [])!;
        
    }
    
    class func getContact(_ user:URUser, completion:@escaping (URContact) -> Void) {
        
        #if DEBUG
            if let token = URCountryProgramManager.getSandboxToken() {
                let headers: [String: String] = [
                    "Authorization": token
                ]
                
                let userId = "fcm:" + URUserManager.formatExtUserId(user.key)
                let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)v1/contacts.json?urns=\(userId)"
                
                Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {
                    (response) in
                    
                    switch response.result {
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        
                    case .success(let value):
                        if let response = value as? NSDictionary {
                            if let results = response["results"] as? [NSDictionary] {
                                for object in results {
                                    let contact = URContact(jsonDict: object)
                                    completion(contact)
                                }
                            }
                        }
                    }
                })
            }
            
        #else
            URCountryProgramAPI.getCountryProgram(countryCode: URCountryProgramManager.activeCountryProgram()!.code) { countryResponse in
                if let countryResponse = countryResponse {
                    let headers = [
                        "Authorization": countryResponse.token
                    ]
                    let userId = "ext:" + URUserManager.formatExtUserId(user.key)
                    let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)v1/contacts.json?urns=\(userId)"
                    
                    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
                        guard let response = response.result.value as? NSDictionary else { return }
                        if let results = response.object(forKey: "results") as? [NSDictionary] {
                            for object in results {
                                let contact = URContact(jsonDict: object)
                                completion(contact)
                            }
                        }
                    }
                }
            }
        #endif
    }
    
    class func sendRulesetResponses(_ user:URUser, responses:[URRulesetResponse], completion:@escaping () -> Void) {
        // Atualizar para v2
        #if DEBUG
            if let token = URCountryProgramManager.getSandboxToken() {
                let userId = URUserManager.formatExtUserId(user.key)
                let url = "https://rapidpro.ilhasoft.mobi/api/v1/external/received/3818d161-a642-4e86-b5af-86e41fc0be2b/"
                
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
        
        #else
        URCountryProgramAPI.getCountryProgram(countryCode: URCountryProgramManager.activeCountryProgram()!.code) { countryResponse in
            guard let countryResponse = countryResponse else { return }

            let token = countryResponse.token
            let channel = URCountryProgramManager.getChannelOfCurrentCountryProgram()

            let userId = URUserManager.formatExtUserId(user.key)
            let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)v1/external/received/\(channel)/"

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
        #endif
    }
    
    class func sendReceivedMessage(_ user:URUser, text:String) {
        // Atualizar para v2
        #if DEBUG
            if let token = URCountryProgramManager.getSandboxToken() {
                let headers = [
                    "Authorization": token
                ]
                
                let channel = URCountryProgramManager.getChannelOfCurrentCountryProgram()
                
                let userId = URUserManager.formatExtUserId(user.key)
                let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)v1/external/received/\(channel)/"
                
                let parameters = [
                    "from": userId,
                    "text": text
                ]
                
                Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            }
        #else
            URCountryProgramAPI.getCountryProgram(countryCode: URCountryProgramManager.activeCountryProgram()!.code) { countryResponse in
                guard let countryResponse = countryResponse else { return }
                
                let headers = [
                    "Authorization": countryResponse.token
                ]
                
                let channel = URCountryProgramManager.getChannelOfCurrentCountryProgram()
                
                let userId = URUserManager.formatExtUserId(user.key)
                let url = "\(URCountryProgramManager.activeCountryProgram()!.rapidProHostAPI!)v1/external/received/\(channel)/"
                
                let parameters = [
                    "from": userId,
                    "text": text
                ]
                
                Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            }
        #endif
    }

    class func getContactFields(_ country:URCountry, completion:@escaping ([String]) -> Void) {
        #if DEBUG
            if let token = URCountryProgramManager.getSandboxToken() {
                let headers = [
                    "Authorization": token
                ]
                Alamofire.request("https://rapidpro.ilhasoft.mobi/api/v1/fields.json", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
                    if let response = response.result.value as? NSDictionary {
                        var arrayFields:[String] = []
                        if let results = response["results"] as? [NSDictionary] {
                            for dictionary in results {
                                arrayFields.append(dictionary.object(forKey:"key") as! String)
                            }
                            completion(arrayFields)
                        } else {
                            completion(arrayFields)
                        }
                    }
                }
            }
            
        #else
            if let countryCode = country.code {
                URCountryProgramAPI.getCountryProgram(countryCode: countryCode) { countryResponse in
                    guard let countryResponse = countryResponse else { return }
                    let headers = [
                        "Authorization": countryResponse.token
                    ]
                    Alamofire.request("\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI!)v1/fields.json", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
                        if let response = response.result.value as? NSDictionary {
                            var arrayFields:[String] = []
                            if let results = response["results"] as? [NSDictionary] {
                                for dictionary in results {
                                    arrayFields.append(dictionary.object(forKey:"key") as! String)
                                }
                                completion(arrayFields)
                            } else {
                                completion(arrayFields)
                            }
                        }
                    }
                }
            }
        #endif
    }

    class func getStatesByCountry(_ country:URCountry, completion:@escaping (_ states:[URState]?,_ districts:[URDistrict]?) -> Void) {
        #if DEBUG
            if let token = URCountryProgramManager.getSandboxToken() {
                let headers = [
                    "Authorization": token
                ]
                Alamofire.request("https://rapidpro.ilhasoft.mobi/api/v1/boundaries.json?aliases=true", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response: DataResponse<Any>) in
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
                            completion(states, districts)
                        } else {
                            completion(nil, nil)
                        }
                    }
                }
            }
        #else
            URCountryProgramAPI.getCountryProgram(countryCode: URCountryProgramManager.activeCountryProgram()!.code) { countryResponse in
                guard let countryResponse = countryResponse else { return }
                let headers = [
                    "Authorization": countryResponse.token
                ]
                Alamofire.request("\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI!)v1/boundaries.json?aliases=true", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response: DataResponse<Any>) in
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
                            completion(states, districts)
                        } else {
                            completion(nil, nil)
                        }
                    }
                }
            }
        #endif
    }

    class func saveUser(_ user:URUser,country:URCountry,setupGroups:Bool,completion:@escaping (_ response:String?) -> Void) {
        #if DEBUG
            if let fcmToken = URSettingsManager.getFCMToken() {

                var params = ["urn": URUserManager.formatExtUserId(user.key),
                              "fcm_token": fcmToken]
                
                if let nickname = user.nickname {
                    params["name"] = nickname
                }

                if let activeCountryProgram = URCountryProgramManager.activeCountryProgram() {
                    if let channel = URCountryProgramManager.getChannelOfCountryProgram(activeCountryProgram) {
                        Alamofire.request("https://rapidpro.ilhasoft.mobi/handlers/fcm/register/\(channel)", method: .post, parameters: params).responseJSON(completionHandler: {
                            (response) in
                            
                            switch response.result {
                                
                            case .failure(let error):
                                print("error \(String(describing: error.localizedDescription))")
                                completion(nil)
                                
                            case .success(let value):
                                if let response = value as? [String: String] {
                                    if let uuid = response["contact_uuid"] {
                                        completion(uuid)
                                    }
                                }
                                
                            }
                        })
                    }
                }
            }
            
        #else
            if let countryCode = country.code {
                URCountryProgramAPI.getCountryProgram(countryCode: countryCode) { countryResponse in
                    guard let countryResponse = countryResponse else { return }
                    let headers = [
                        "Authorization": countryResponse.token
                    ]
                    URRapidProContactUtil.buildRapidProUserRootDictionary(user, setupGroups: setupGroups) { (rootDicionary) in
                        print("===============")
                        print(rootDicionary.copy())
                        print("\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI!)v1/contacts.json")
                        print(headers)
                        print("===============")
                        Alamofire.request("\(URCountryProgramManager.getCountryProgramByCountry(country).rapidProHostAPI!)v1/contacts.json", method: .post, parameters: rootDicionary.copy() as? [String : AnyObject] , encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response: DataResponse<Any>) in
                            if response.result.isFailure {
                                print("error \(String(describing: response.result.value))")
                                completion(nil)
                            } else if let response = response.result.value as? NSDictionary {
                                completion(response)
                            }
                        })
                    }
                }
            }
        #endif
    }
}

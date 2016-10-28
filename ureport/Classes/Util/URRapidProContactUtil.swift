//
//  URRapidProContactUtil.swift
//  ureport
//
//  Created by Daniel Amaral on 15/01/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class URRapidProContactUtil: NSObject {
    
    static var rapidProUser = NSMutableDictionary()
    
    static let YOUTH_MIN_BIRTHDAY_YEAR = 1979
    
    static let GROUP_UREPORT_YOUTH = "UReport Youth"
    static let GROUP_UREPORT_ADULTS = "UReport Adults"
    static let GROUP_UREPORT_MALES = "UReport Males"
    static let GROUP_UREPORT_FEMALES = "UReport Females"
    static let GROUP_APP_UREPORT = "App U-Reporters"
    
    static var groupList:[String] = []
    
    class func putValueIfExists(_ value:String?,countryProgramContactFields:[String],possibleFields:[String]) {
        if value == nil || value!.characters.count == 0{
            return
        }
        
        for possibleField in possibleFields {
            let index = countryProgramContactFields.index(of: possibleField)
            if index != nil && index != -1{
                let field = countryProgramContactFields[index!]
                URRapidProContactUtil.rapidProUser.setValue(value, forKey: field)
                break
            }
        }
    }
    
    class func buildRapidProUserDictionaryWithContactFields(_ user:URUser,country:URCountry,completion:@escaping (NSDictionary) -> Void) {
        
        URRapidProManager.getContactFields(URCountry(code: user.country)) { (contactFields:[String]) -> Void in
            if !contactFields.isEmpty {
                
                let countryProgram = URCountryProgramManager.getCountryProgramByCountry(URCountry(code: user.country))
                
                var age = 0
                
                if user.birthday != nil {
                    age = (Calendar.current as NSCalendar).components(.year, from: Date(timeIntervalSince1970: NSNumber(value: user.birthday.doubleValue/1000 as Double) as TimeInterval), to: URDateUtil.currentDate(), options: []).year!
                    
                    URRapidProContactUtil.putValueIfExists(URDateUtil.birthDayFormatterRapidPro(Date(timeIntervalSince1970: NSNumber(value: user.birthday.doubleValue/1000 as Double) as TimeInterval)), countryProgramContactFields: contactFields, possibleFields: ["birthday","birthdate","birth_day","date_of_birth"])
                    URRapidProContactUtil.putValueIfExists(String(age), countryProgramContactFields: contactFields, possibleFields: ["age"])
                    URRapidProContactUtil.putValueIfExists(String(URDateUtil.getYear(Date(timeIntervalSince1970: NSNumber(value: user.birthday.doubleValue/1000 as Double) as TimeInterval))), countryProgramContactFields: contactFields, possibleFields: ["year_of_birth","born"])
                }
                
//                URRapidProContactUtil.putValueIfExists(user.email, countryProgramContactFields: contactFields, possibleFields: ["email","e_mail"])
                URRapidProContactUtil.putValueIfExists(user.nickname, countryProgramContactFields: contactFields, possibleFields: ["nickname","nick_name"])
                URRapidProContactUtil.putValueIfExists(user.gender, countryProgramContactFields: contactFields, possibleFields: ["gender"])
                URRapidProContactUtil.putValueIfExists(user.state, countryProgramContactFields: contactFields, possibleFields: countryProgram.stateField != nil ? [countryProgram.stateField!] : ["state","region","province","county"])
                URRapidProContactUtil.putValueIfExists(user.district, countryProgramContactFields: contactFields, possibleFields: ["location","district","lga"])
                URRapidProContactUtil.putValueIfExists(country.code, countryProgramContactFields: contactFields, possibleFields: ["country"])
                completion(URRapidProContactUtil.rapidProUser)
            }
        }
        
    }
    
    class func buildRapidProUserRootDictionary(_ user:URUser,setupGroups:Bool,completion:@escaping (_ rootDicionary:NSDictionary) -> Void) {
        
        URRapidProContactUtil.addGenderGroup(user)
        URRapidProContactUtil.addAgeGroup(user)
        
        groupList.append(URCountryProgramManager.getCountryProgramByCountry(URCountry(code: user.country)).groupName)
        groupList.append(GROUP_APP_UREPORT)
        
        let rootDictionary = NSMutableDictionary()
        
        rootDictionary.setValue(URRapidProContactUtil.rapidProUser, forKey: "fields")
        rootDictionary.setValue(["ext:\(URUserManager.formatExtUserId(user.key))"], forKey: "urns")
        rootDictionary.setValue(user.nickname, forKey:"name")
        rootDictionary.setValue(user.email, forKey:"email")
        
        if setupGroups == true {
            rootDictionary.setValue(groupList, forKey: "groups")
            
            let timeZone = TimeZone.autoupdatingCurrent.identifier
            
            Alamofire.request("http://api.timezonedb.com/?zone=\(timeZone)&format=json&key=8JU9ZQELCDX6", method: .get , parameters: nil, encoding: JSONEncoding.default, headers: nil).responseObject(completionHandler: { (response:DataResponse<URServerDateTime>) -> Void in
                
                var registrationDate = URDateUtil.currentDate()
                
                if let serverDateTime = response.result.value {
                    if serverDateTime.status != nil && serverDateTime.status != "FAIL" {
                        registrationDate = NSDate(timeIntervalSince1970: Double(serverDateTime.timestamp)) as Date
                    }
                }
                
                let dateFormat = DateFormatter()
                dateFormat.calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) as Calendar!
                dateFormat.dateFormat = "MM/dd/yyyy"
                
                URRapidProContactUtil.rapidProUser.setValue(dateFormat.string(from: registrationDate), forKey: "registration_date")
                completion(rootDictionary)
            })
        }else{
            completion(rootDictionary)
        }
    }
    
    class func addGenderGroup(_ user:URUser) {
        if user.gender == "Male" {
            groupList.append(GROUP_UREPORT_MALES)
        }else {
            groupList.append(GROUP_UREPORT_FEMALES)
        }
        
    }
    
    class func addAgeGroup(_ user:URUser) {
        if user.birthday != nil {
            if URDateUtil.getYear(Date(timeIntervalSince1970: NSNumber(value: user.birthday.doubleValue/1000 as Double) as TimeInterval)) >= YOUTH_MIN_BIRTHDAY_YEAR {
                groupList.append(GROUP_UREPORT_YOUTH)
            }else {
                groupList.append(GROUP_UREPORT_ADULTS)
            }
        }
    }
    
}

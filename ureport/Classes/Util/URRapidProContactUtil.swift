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
    
    class func putValueIfExists(value:String?,countryProgramContactFields:[String],possibleFields:[String]) {
        if value == nil || value!.characters.count == 0{
            return
        }
        
        for possibleField in possibleFields {
            let index = countryProgramContactFields.indexOf(possibleField)
            if index != nil && index != -1{
                let field = countryProgramContactFields[index!]
                URRapidProContactUtil.rapidProUser.setValue(value, forKey: field)
                break
            }
        }
    }
    
    class func buildRapidProUserDictionaryWithContactFields(user:URUser,country:URCountry,completion:(NSDictionary) -> Void) {
        
        URRapidProManager.getContactFields(URCountry(code: user.country)) { (contactFields:[String]) -> Void in
            if !contactFields.isEmpty {
                
                var age = 0
                
                if user.birthday != nil {
                    age = NSCalendar.currentCalendar().components(.Year, fromDate: NSDate(timeIntervalSince1970: NSNumber(double: user.birthday.doubleValue/1000) as NSTimeInterval), toDate: NSDate(), options: []).year
                    
                    URRapidProContactUtil.putValueIfExists(URDateUtil.birthDayFormatterRapidPro(NSDate(timeIntervalSince1970: NSNumber(double: user.birthday.doubleValue/1000) as NSTimeInterval)), countryProgramContactFields: contactFields, possibleFields: ["birthday","birthdate","birth_day","date_of_birth"])
                    URRapidProContactUtil.putValueIfExists(String(age), countryProgramContactFields: contactFields, possibleFields: ["age"])
                    URRapidProContactUtil.putValueIfExists(String(URDateUtil.getYear(NSDate(timeIntervalSince1970: NSNumber(double: user.birthday.doubleValue/1000) as NSTimeInterval))), countryProgramContactFields: contactFields, possibleFields: ["year_of_birth","born"])
                }
                
//                URRapidProContactUtil.putValueIfExists(user.email, countryProgramContactFields: contactFields, possibleFields: ["email","e_mail"])
                URRapidProContactUtil.putValueIfExists(user.nickname, countryProgramContactFields: contactFields, possibleFields: ["nickname","nick_name"])
                URRapidProContactUtil.putValueIfExists(user.gender, countryProgramContactFields: contactFields, possibleFields: ["gender"])
                URRapidProContactUtil.putValueIfExists(user.state, countryProgramContactFields: contactFields, possibleFields: ["state","region","province","county"])
                URRapidProContactUtil.putValueIfExists(user.district, countryProgramContactFields: contactFields, possibleFields: ["location","district","lga"])
                URRapidProContactUtil.putValueIfExists(country.code, countryProgramContactFields: contactFields, possibleFields: ["country"])
                completion(URRapidProContactUtil.rapidProUser)
            }
        }
        
    }
    
    class func buildRapidProUserRootDictionary(user:URUser,setupGroups:Bool,completion:(rootDicionary:NSDictionary) -> Void) {
        
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
            
            let timeZone = NSTimeZone.localTimeZone().name
            
            Alamofire.request(.GET, "http://api.timezonedb.com/?zone=\(timeZone)&format=json&key=8JU9ZQELCDX6", parameters: nil, encoding: .JSON, headers: nil).responseObject({ (response:URServerDateTime?, error:ErrorType?) -> Void in
                
                var registrationDate = NSDate()
                
                if let serverDateTime = response {
                    if serverDateTime.status != nil && serverDateTime.status != "FAIL" {
                        registrationDate = NSDate(timeIntervalSince1970: Double(serverDateTime.timestamp))
                    }
                }
                
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "MM/dd/yyyy"
                
                URRapidProContactUtil.rapidProUser.setValue(dateFormat.stringFromDate(registrationDate), forKey: "registration_date")
                completion(rootDicionary: rootDictionary)
            })
        }else{
            completion(rootDicionary: rootDictionary)
        }
    }
    
    class func addGenderGroup(user:URUser) {
        if user.gender == "Male" {
            groupList.append(GROUP_UREPORT_MALES)
        }else {
            groupList.append(GROUP_UREPORT_FEMALES)
        }
        
    }
    
    class func addAgeGroup(user:URUser) {
        if user.birthday != nil {
            if URDateUtil.getYear(NSDate(timeIntervalSince1970: NSNumber(double: user.birthday.doubleValue/1000) as NSTimeInterval)) >= YOUTH_MIN_BIRTHDAY_YEAR {
                groupList.append(GROUP_UREPORT_YOUTH)
            }else {
                groupList.append(GROUP_UREPORT_ADULTS)
            }
        }
    }
    
}
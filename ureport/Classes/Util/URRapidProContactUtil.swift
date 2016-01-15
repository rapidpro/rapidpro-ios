//
//  URRapidProContactUtil.swift
//  ureport
//
//  Created by Daniel Amaral on 15/01/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URRapidProContactUtil: NSObject {

    static let rapidProUser = NSMutableDictionary()
    
    static let YOUTH_MIN_BIRTHDAY_YEAR = 1979
    
    static let GROUP_UREPORT_YOUTH = "UReport Youth"
    static let GROUP_UREPORT_ADULTS = "UReport Adults"
    static let GROUP_UREPORT_MALES = "UReport Males"
    static let GROUP_UREPORT_FEMALES = "UReport Females"
    static let GROUP_UREPORT_APP = "App U-Reporters"
    
    static var groupList = [GROUP_UREPORT_APP]
    
    
    class func putValueIfExists(value:String?,countryProgramContactFields:[String],possibleFields:[String]) {
        if value == nil {
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
        
        URRapidProManager.getContactFields(country) { (contactFields:[String]) -> Void in
            if !contactFields.isEmpty {
                URRapidProContactUtil.putValueIfExists(user.email, countryProgramContactFields: contactFields, possibleFields: ["email","e_mail"])
                URRapidProContactUtil.putValueIfExists(user.nickname, countryProgramContactFields: contactFields, possibleFields: ["nickname","nick_name"])
                URRapidProContactUtil.putValueIfExists(URDateUtil.birthDayFormatterRapidPro(NSDate(timeIntervalSince1970: NSNumber(double: user.birthday.doubleValue/1000) as NSTimeInterval)), countryProgramContactFields: contactFields, possibleFields: ["birthday","birthdate","birth_day"])
                URRapidProContactUtil.putValueIfExists(String(URDateUtil.getYear(NSDate(timeIntervalSince1970: NSNumber(double: user.birthday.doubleValue/1000) as NSTimeInterval))), countryProgramContactFields: contactFields, possibleFields: ["born"])
                URRapidProContactUtil.putValueIfExists(user.gender == URGender.Male ? "Male" : "Female", countryProgramContactFields: contactFields, possibleFields: ["gender"])
                URRapidProContactUtil.putValueIfExists(user.state, countryProgramContactFields: contactFields, possibleFields: ["state","region","province","county"])
                URRapidProContactUtil.putValueIfExists(user.district, countryProgramContactFields: contactFields, possibleFields: ["district","lga"])
                URRapidProContactUtil.putValueIfExists(user.country, countryProgramContactFields: contactFields, possibleFields: ["country"])
                completion(URRapidProContactUtil.rapidProUser)
            }
        }
        
    }
    
    class func buildRapidProUserRootDictionary(user:URUser) -> NSDictionary {
        
        URRapidProContactUtil.addGenderGroup(user)
        URRapidProContactUtil.addAgeGroup(user)
        
        let rootDictionary = NSMutableDictionary()
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        
        URRapidProContactUtil.rapidProUser.setValue(dateFormat.stringFromDate(NSDate()), forKey: "registration_date")
        rootDictionary.setValue(URRapidProContactUtil.rapidProUser, forKey: "fields")
        rootDictionary.setValue(["ext:\(URUserManager.formatExtUserId(user.key))"], forKey: "urns")
        rootDictionary.setValue(user.nickname, forKey:"name")
        rootDictionary.setValue(groupList, forKey: "groups")
        return rootDictionary
    }
    
    class func addGenderGroup(user:URUser) {
        if user.gender == URGender.Male {
            groupList.append(GROUP_UREPORT_MALES)
        }else {
            groupList.append(GROUP_UREPORT_FEMALES)
        }
        
    }
    
    class func addAgeGroup(user:URUser) {
        if URDateUtil.getYear(NSDate(timeIntervalSince1970: NSNumber(double: user.birthday.doubleValue/1000) as NSTimeInterval)) >= YOUTH_MIN_BIRTHDAY_YEAR {
            groupList.append(GROUP_UREPORT_YOUTH)
        }else {
            groupList.append(GROUP_UREPORT_ADULTS)
        }
    }
    
}

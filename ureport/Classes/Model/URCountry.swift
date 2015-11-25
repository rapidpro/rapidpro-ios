//
//  URCountry.swift
//  ureport
//
//  Created by Daniel Amaral on 09/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

enum URCountryCodeType {
    case ISO2
    case ISO3
}

class URCountry: NSObject {

    var code:String?
    var name:String?
    
    init(code:String) {
        self.code = code
        super.init()
    }
    
    override init() {
    }
    
    class func getCountries(type:URCountryCodeType) -> AnyObject {

        var countries: [URCountry] = []
        
        for code in NSLocale.ISOCountryCodes() {
            let country:URCountry? = URCountry()
            
            let id = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode: code])
            let name = NSLocale(localeIdentifier: NSLocale.preferredLanguages()[0] ).displayNameForKey(NSLocaleIdentifier, value: id) ?? "Country not found for code: \(code)"
            
            if type == .ISO3 {
                country!.code = getISO3CountryCodeByISO2Code(code)
            }else {
                country!.code = code
            }
            
            country!.name = name            
            countries.append(country!)
        }
        
        countries.sortInPlace({ $0.name < $1.name })
        
        return countries
        
    }
    
    class func getCurrentURCountry() -> URCountry {
        let country:URCountry? = URCountry()
        
        let locale:NSLocale! = NSLocale.currentLocale()
        country!.code = locale.objectForKey(NSLocaleCountryCode) as? String
        country!.name = locale.displayNameForKey(NSLocaleCountryCode, value: country!.code!)
        return country!
    }

    class func getISO3CountryCodeByISO2Code(code:String) -> String{
        if let path = NSBundle.mainBundle().pathForResource("iso3-country-code", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
                    if let ISO3Code : String = jsonResult[code] as? String {
                        return ISO3Code
                    }
                } catch let error as NSError {
                    print("error2 \(error.localizedDescription)")
                }
            }catch let error as NSError {
                print("error1 \(error.localizedDescription)")
            }
            
        }
        
        return ""
    }
    
}

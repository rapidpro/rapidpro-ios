//
//  URCountry.swift
//  ureport
//
//  Created by Daniel Amaral on 09/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


enum URCountryCodeType {
    case iso2
    case iso3
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
    
    class func getLanguageDescription(_ languageCode:String, type:URCountryCodeType) -> String? {
        var languageCode = languageCode
        if type == .iso3 {
            let keys = (NSLocale.iso639_2Dictionary() as NSDictionary).allKeys(for: languageCode)
            languageCode = keys.count > 0 ? keys.first as! String : languageCode
        }
        
        let id = Locale.identifier(fromComponents: [Locale.current.currencyCode!: languageCode])
        return (Locale(identifier: Locale.preferredLanguages[0]) as NSLocale).displayName(forKey: NSLocale.Key(rawValue: Locale.current.currencyCode!), value: id)
    }
    
    class func getCountries(_ type:URCountryCodeType) -> [URCountry] {
        
        var countries: [URCountry] = []
        
        for code in Locale.isoRegionCodes {
            let country:URCountry? = URCountry()
            
            let id = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = (Locale(identifier: Locale.preferredLanguages[0] ) as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            
            if type == .iso3 {
                country!.code = getISO3CountryCodeByISO2Code(code)
            }else {
                country!.code = code
            }
            
            country!.name = name
            countries.append(country!)
        }
        
        
        let sortedCountries = countries.sorted(by: { $0.name < $1.name })
        
        return sortedCountries
        
    }
    
    class func getCurrentURCountry() -> URCountry {
        let country:URCountry? = URCountry()
        
        let locale = Locale.current
        country!.code = locale.regionCode
        country!.name = locale.localizedString(forRegionCode: locale.regionCode!)
        return country!
    }
    
    class func getISO3CountryCodeByISO2Code(_ code:String) -> String{
        if let path = Bundle.main.path(forResource: "iso3-country-code", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe)
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    if let ISO3Code = jsonResult[code] as? String {
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
    
    class func getISO2CountryCodeByISO3Code(_ code:String) -> String{
        if let path = Bundle.main.path(forResource: "iso3-country-code", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe)
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    let filtered = (jsonResult as! NSDictionary).filter({ $0.1 as! String == code })
                    
                    if !filtered.isEmpty {
                        return filtered[0].key as! String
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

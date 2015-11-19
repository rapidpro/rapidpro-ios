//
//  URCountryProgramManager.swift
//  ureport
//
//  Created by Daniel Amaral on 09/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URCountryProgramManager: NSObject {
   
    static var countryPrograms:[URCountryProgram]!
    
    class func getCountryProgramByCountry(country:URCountry) -> URCountryProgram {
        
        if countryPrograms == nil {
            URCountryProgramManager.getAvailableCountryPrograms()
        }
        
        let filtered = countryPrograms.filter {
            return $0.code == country.code!
        }
        
        if filtered.isEmpty {
            return countryPrograms[0] as URCountryProgram
        }else {
            return filtered[0] as URCountryProgram
        }
        
    }
    
    class func getAvailableCountryPrograms() -> [URCountryProgram]{
        
        if countryPrograms == nil {
            countryPrograms = []
            countryPrograms.append(URCountryProgram(code: "GLOBAL", theme: nil, org:13, name: "U-Report Global",twitter:"UReportGlobal",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "BDI", theme: nil, org:5, name: "Burundi",twitter:nil,facebook:nil))
            countryPrograms.append(URCountryProgram(code: "CMR", theme: nil, org:10, name: "Cameroun",twitter:"UReportCameroon",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "CHL", theme: nil, org:12, name: "Chile",twitter:"UReportChile",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "COD", theme: nil, org:nil, name: "DRC",twitter:"UReportDRC",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "IDN", theme: nil, org:15, name: "Indonesia",twitter:"UReport_id",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "LBR", theme: nil, org:6, name: "Liberia",twitter:"UReportLiberia",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "MLI", theme: nil, org:3, name: "Mali",twitter:"UReportMali",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "MEX", theme: nil, org:9, name: "México",twitter:"UreportMexico",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "NGA", theme: nil, org:1, name: "Nigeria",twitter:"UReportNigeria",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "PAK", theme: nil, org:16, name: "Pakistan",twitter:"PakAvaz",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "CAF", theme: nil, org:8, name: "République Centrafricaine",twitter:nil,facebook:nil))
            countryPrograms.append(URCountryProgram(code: "SEN", theme: nil, org:14, name: "Sénégal",twitter:"ureportsenegal",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "SLE", theme: nil, org:7, name: "Sierra Leone",twitter:"UreportSL",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "SWZ", theme: nil, org:4, name: "Swaziland",twitter:"Ureportszd",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "UGA", theme: nil, org:nil, name: "Uganda",twitter:"UReportUganda",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "ZMB", theme: nil, org:nil, name: "Zambia",twitter:"ZambiaUReport",facebook:nil))
            countryPrograms.append(URCountryProgram(code: "ZWE", theme: nil, org:2, name: "Zimbabwe",twitter:"Ureportzim",facebook:nil))
        }
        
        return countryPrograms
        
    }
    
    class func getChannelOfCountryProgram(countryProgram:URCountryProgram) -> String?{
        
        var myDict: NSDictionary?
        var channel:String?
        
        if let path = NSBundle.mainBundle().pathForResource(URFireBaseManager.Properties, ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = myDict {
            
            if dict["\(URConstant.Key.COUNTRY_PROGRAM_CHANNEL)\(countryProgram.code)"] != nil {
                channel = dict["\(URConstant.Key.COUNTRY_PROGRAM_CHANNEL)\(countryProgram.code)"] as? String
            }else {
                channel = dict["\(URConstant.Key.COUNTRY_PROGRAM_CHANNEL)\(URConstant.RapidPro.GLOBAL)"] as? String
            }
            
        }
        
        return channel
        
    }
    
    class func getTokenOfCountryProgram(countryProgram:URCountryProgram) -> String? {
        
        var rootDictionary: NSDictionary?
        var token:String?

        if let path = NSBundle.mainBundle().pathForResource(URFireBaseManager.Properties, ofType: "plist") {
            rootDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = rootDictionary {
            
            if dict["\(URConstant.Key.COUNTRY_PROGRAM_TOKEN)\(countryProgram.code)"] != nil {
                token = dict["\(URConstant.Key.COUNTRY_PROGRAM_TOKEN)\(countryProgram.code)"] as? String
            }else {
                token = dict["\(URConstant.Key.COUNTRY_PROGRAM_TOKEN)\(URConstant.RapidPro.GLOBAL)"] as? String
            }
            
        }
        
        return token
        
    }
    
    class func getChannelOfCurrentCountryProgram() -> String {
        return URCountryProgramManager.getChannelOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
    }

    class func activeCountryProgram() -> URCountryProgram? {
        
        if let countryProgram = URCountryProgramManager.activeSwitchCountryProgram() {
            return countryProgram
        }
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var encodedData: NSData?
        
        encodedData = defaults.objectForKey("countryProgram") as? NSData
        
        if encodedData != nil {
            let countryProgram = URCountryProgram(jsonDict: NSKeyedUnarchiver.unarchiveObjectWithData(encodedData!) as? NSDictionary)
            return countryProgram
        }else{
            return URCountryProgramManager.getAvailableCountryPrograms()[0]
        }
        
    }
    
    class func setActiveCountryProgram(countryProgram: URCountryProgram!) {
        self.deactivateCountryProgram()
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let encodedObject: NSData = NSKeyedArchiver.archivedDataWithRootObject(countryProgram.toDictionary())
        defaults.setObject(encodedObject, forKey: "countryProgram")
        defaults.synchronize()
    }
    
    class func deactivateCountryProgram() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("countryProgram")
        defaults.synchronize()
    }
    
    class func setSwitchActiveCountryProgram(countryProgram: URCountryProgram!) {
        self.deactivateSwitchCountryProgram()
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let encodedObject: NSData = NSKeyedArchiver.archivedDataWithRootObject(countryProgram.toDictionary())
        defaults.setObject(encodedObject, forKey: "countryProgram_switch")
        defaults.synchronize()
    }
    
    class func deactivateSwitchCountryProgram() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("countryProgram_switch")
        defaults.synchronize()
    }

    class func activeSwitchCountryProgram() -> URCountryProgram? {
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var encodedData: NSData?
        
        encodedData = defaults.objectForKey("countryProgram_switch") as? NSData
        
        if encodedData != nil {
            let countryProgram = URCountryProgram(jsonDict: NSKeyedUnarchiver.unarchiveObjectWithData(encodedData!) as? NSDictionary)
            return countryProgram
        }else{
            return nil
        }
        
    }
    
}

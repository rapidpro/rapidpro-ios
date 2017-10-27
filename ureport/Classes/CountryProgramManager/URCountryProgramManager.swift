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
    fileprivate static var countryProgram:URCountryProgram?
    
    class func getCountryProgramByCountry(_ country:URCountry) -> URCountryProgram {
        #if ONTHEMOVE
            return getOtmProgram()
        #else
            return getUReportProgram(country)
        #endif
    }
    
    //MARK: On The Move
    class func getOtmProgram() -> URCountryProgram {
        if countryProgram == nil {
            countryProgram = URCountryProgram(code: "OTM", themeColor: URConstant.Color.PRIMARY, org:33, name: "On The Move", twitter:nil, facebook:nil, rapidProHostAPI: URConstant.RapidPro.API_URL_ILHA, ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters")
        }
        return countryProgram!
    }

    //MARK: U-Report
    class func getUReportProgram(_ country: URCountry) -> URCountryProgram {
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
            countryPrograms.append(URCountryProgram(code: "GLOBAL", themeColor: URConstant.Color.PRIMARY, org:13, name: "U-Report Global",twitter:"UReportGlobal",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "BRA", themeColor: UIColor(rgba: "#00a200"), org:1,   name: "Brasil",         twitter:"ureportbrasil",facebook:"UNICEFBrasil",rapidProHostAPI: URConstant.RapidPro.API_URL_ILHA,ureportHostAPI: "http://brasil.ureport.in/api/v1/stories/org/", groupName: "UReport Brasil"))
            countryPrograms.append(URCountryProgram(code: "BDI", themeColor: UIColor(rgba: "#00a418"), org:5,     name: "Burundi",        twitter:nil,facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "CMR", themeColor: UIColor(rgba: "#00a400"), org:10,    name: "Cameroun",       twitter:"UReportCameroon",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "CHL", themeColor: UIColor(rgba: "#c6002a"), org:12,    name: "Chile",          twitter:"UReportChile",facebook:"ureportchile",rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "UReporters"))
            
            countryPrograms.append(URCountryProgram(code: "CIV", themeColor: UIColor(rgba: "#00a200"), org:26,    name: "Côte d'Ivoire",          twitter:nil,facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "UReporters"))
            
            countryPrograms.append(URCountryProgram(code: "COD", themeColor: UIColor(rgba: "#05b5e8"), org:nil,   name: "DRC",            twitter:"UReportDRC",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            
            countryPrograms.append(URCountryProgram(code: "SLV", themeColor: URConstant.Color.PRIMARY, org:10,   name: "El Salvador",         twitter:nil,facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL_ILHA,ureportHostAPI: "http://elsalvador.ureport.in/api/v1/stories/org/", groupName: "U-Reporters"))
            
            countryPrograms.append(URCountryProgram(code: "FJI", themeColor: UIColor(rgba: "#05b5e8"), org:9,     name: "Fiji",        twitter:nil,facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "UReporters"))
            countryPrograms.append(URCountryProgram(code: "GTM", themeColor: UIColor(rgba: "#3B85C5"), org:7,     name: "Guatemala",        twitter:"UReportGua",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL_ILHA,ureportHostAPI: "http://guatemala.ureport.in/api/v1/stories/org/", groupName: "U-Reporters",stateField:"department"))
            countryPrograms.append(URCountryProgram(code: "IRL", themeColor: UIColor(rgba: "#00a200"), org:2,   name: "Ireland",         twitter:"UReportIRL",facebook:"Unicefitsaboutus",rapidProHostAPI: URConstant.RapidPro.API_URL_ILHA,ureportHostAPI: "http://ireland.ureport.in/api/v1/stories/org/", groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "IDN", themeColor: UIColor(rgba: "#b9001c"), org:15,    name: "Indonesia",      twitter:"UReport_id",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "UReporters_Indonesia"))
            countryPrograms.append(URCountryProgram(code: "LBR", themeColor: UIColor(rgba: "#155ad0"), org:6,     name: "Liberia",        twitter:"UReportLiberia",facebook:"ureport.liberia",rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "MLI", themeColor: UIColor(rgba: "#d7001d"), org:3,     name: "Mali",           twitter:"UReportMali",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "MEX", themeColor: UIColor(rgba: "#00a400"), org:9,     name: "México",         twitter:"UreportMexico",facebook:"UReportMexico",rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "ITA", themeColor: URConstant.Color.PRIMARY, org:33,     name: "On The Move",         twitter:nil,facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))            
            countryPrograms.append(URCountryProgram(code: "MYS", themeColor: UIColor(rgba: "#155ad0"), org:9,     name: "Malaysia",        twitter:"UReportMalaysia",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "MMR", themeColor: UIColor(rgba: "#00a400"), org:9,     name: "Myanmar",        twitter:"UReportMyanmar",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "NGA", themeColor: UIColor(rgba: "#00a200"), org:1,     name: "Nigeria",        twitter:"UReportNigeria",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "PAK", themeColor: UIColor(rgba: "#00a200"), org:16,    name: "Pakistan",       twitter:"PakAvaz",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            
            countryPrograms.append(URCountryProgram(code: "PNG", themeColor: UIColor(rgba: "#c6002a"), org:28,    name: "Papua New Guinea",       twitter:nil,facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            
            countryPrograms.append(URCountryProgram(code: "CAF", themeColor: UIColor(rgba: "#d70020"), org:8,     name: "République Centrafricaine",twitter:nil,facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "SEN", themeColor: UIColor(rgba: "#00a400"), org:14,    name: "Sénégal",        twitter:"ureportsenegal",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "SLE", themeColor: UIColor(rgba: "#41b646"), org:7,     name: "Sierra Leone",   twitter:"UreportSL",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "SWZ", themeColor: UIColor(rgba: "#d7001c"), org:4,     name: "Swaziland",      twitter:"Ureportszd",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "SYR", themeColor: UIColor(rgba: "#C1001D"), org:6,     name: "Syria",      twitter:nil,facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL_ILHA,ureportHostAPI: "http://syria.ureport.in/api/v1/stories/org/", groupName: "U-Reporters"))
            
            countryPrograms.append(URCountryProgram(code: "THA", themeColor: UIColor(rgba: "#1B143E"), org:5,     name: "Thailand",      twitter:"UReportThai",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL_ILHA,ureportHostAPI: "http://thailand.ureport.in/api/v1/stories/org/", groupName: "U-Reporters",stateField:"province"))
            
            countryPrograms.append(URCountryProgram(code: "TUN", themeColor: UIColor.red, org:31,     name: "Tunisie",      twitter:nil,facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL ,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            
            countryPrograms.append(URCountryProgram(code: "UGA", themeColor: UIColor(rgba: "#d6001f"), org:18,   name: "Uganda",         twitter:"UReportUganda",facebook:"UReportUganda",rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            
            countryPrograms.append(URCountryProgram(code: "GBR", themeColor: UIColor(rgba: "#00166B"), org:3,     name: "United Kingdom",      twitter:"UReportThai",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL_ILHA,ureportHostAPI: "http://uk.ureport.in/api/v1/stories/org/", groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "UKR", themeColor: UIColor(rgba: "#00166B"), org:19,   name: "Ukraine",         twitter:nil,facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            
            countryPrograms.append(URCountryProgram(code: "ZMB", themeColor: UIColor(rgba: "#00a200"), org:nil,   name: "Zambia",         twitter:"ZambiaUReport",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
            countryPrograms.append(URCountryProgram(code: "ZWE", themeColor: UIColor(rgba: "#155ad0"), org:2,     name: "Zimbabwe",       twitter:"Ureportzim",facebook:nil,rapidProHostAPI: URConstant.RapidPro.API_URL,ureportHostAPI: URConstant.RapidPro.API_NEWS, groupName: "U-Reporters"))
        }
        
        return countryPrograms
        
    }
    
    class func getChannelOfCountryProgram(_ countryProgram:URCountryProgram) -> String?{
        
        var myDict: NSDictionary?
        var channel:String?
        
        if let path = Bundle.main.path(forResource: URFireBaseManager.Properties, ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = myDict {
            
            if dict["\(URConstant.Key.COUNTRY_PROGRAM_CHANNEL)\(countryProgram.code!)"] != nil {
                channel = dict["\(URConstant.Key.COUNTRY_PROGRAM_CHANNEL)\(countryProgram.code!)"] as? String
            }else {
                channel = dict["\(URConstant.Key.COUNTRY_PROGRAM_CHANNEL)\(URConstant.RapidPro.GLOBAL)"] as? String
            }
            
        }
        
        return channel
        
    }
    
    class func getTokenOfCountryProgram(_ countryProgram:URCountryProgram) -> String? {
        
        var rootDictionary: NSDictionary?
        var token:String?
        
        if let path = Bundle.main.path(forResource: URFireBaseManager.Properties, ofType: "plist") {
            rootDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = rootDictionary {
            
            if dict["\(URConstant.Key.COUNTRY_PROGRAM_TOKEN)\(countryProgram.code!)"] != nil {
                token = dict["\(URConstant.Key.COUNTRY_PROGRAM_TOKEN)\(countryProgram.code!)"] as? String
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
        
        let defaults: UserDefaults = UserDefaults.standard
        var encodedData: Data?
        
        encodedData = defaults.object(forKey: "countryProgram") as? Data
        
        if encodedData != nil {
            let countryProgram = URCountryProgram(jsonDict: NSKeyedUnarchiver.unarchiveObject(with: encodedData!) as? NSDictionary)
            return countryProgram
        }else{
            return URCountryProgramManager.getAvailableCountryPrograms()[0]
        }
        
    }
    
    class func setActiveCountryProgram(_ countryProgram: URCountryProgram!) {
        self.deactivateCountryProgram()
        let defaults: UserDefaults = UserDefaults.standard
        let encodedObject: Data = NSKeyedArchiver.archivedData(withRootObject: countryProgram.toDictionary())
        defaults.set(encodedObject, forKey: "countryProgram")
        defaults.synchronize()
    }
    
    class func deactivateCountryProgram() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: "countryProgram")
        defaults.synchronize()
    }
    
    class func setSwitchActiveCountryProgram(_ countryProgram: URCountryProgram!) {
        self.deactivateSwitchCountryProgram()
        let defaults: UserDefaults = UserDefaults.standard
        let encodedObject: Data = NSKeyedArchiver.archivedData(withRootObject: countryProgram.toDictionary())
        defaults.set(encodedObject, forKey: "countryProgram_switch")
        defaults.synchronize()
    }
    
    class func deactivateSwitchCountryProgram() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: "countryProgram_switch")
        defaults.synchronize()
    }
    
    class func activeSwitchCountryProgram() -> URCountryProgram? {
        
        let defaults: UserDefaults = UserDefaults.standard
        var encodedData: Data?
        
        encodedData = defaults.object(forKey: "countryProgram_switch") as? Data
        
        if encodedData != nil {
            let countryProgram = URCountryProgram(jsonDict: NSKeyedUnarchiver.unarchiveObject(with: encodedData!) as? NSDictionary)
            return countryProgram
        }else{
            return nil
        }
        
    }
    
}

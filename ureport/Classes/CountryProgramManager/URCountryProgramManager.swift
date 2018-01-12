//
//  URCountryProgramManager.swift
//  ureport
//
//  Created by Daniel Amaral on 09/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URCountryProgramManager {

    static var countryPrograms:[URCountryProgram]!
    fileprivate static var countryProgram:URCountryProgram?
    
    class func getCountryProgramByCountry(_ country:URCountry) -> URCountryProgram {
        #if ONTHEMOVE
            return getOtmProgram()
        #else
            return getUReportProgram(country)
        #endif
    }
    
    class func getToken(for userProgram: String) -> String? {
        var fileName: String!
        switch AppDelegate.environment {
        case .sandbox:
            fileName = "Key-debug"
        case .production:
            fileName = "Key"
        }
        
        guard let dictPath = Bundle.main.path(forResource: fileName, ofType: "plist"), let dict = NSDictionary(contentsOfFile: dictPath) else {return nil}
        
        var userProgram = userProgram
        #if ONTHEMOVE
            userProgram = "OTM"
        #endif
        
        return dict["\(URConstant.Key.COUNTRY_PROGRAM_TOKEN)\(userProgram)"] as? String
    }
    
    class func getChannelToken(for userProgram: String) -> String? {
        var fileName: String!
        switch AppDelegate.environment {
        case .sandbox:
            fileName = "Key-debug"
        case .production:
            fileName = "Key"
        }
        
        guard let dictPath = Bundle.main.path(forResource: fileName, ofType: "plist"), let dict = NSDictionary(contentsOfFile: dictPath) else {return nil}

        var userProgram = userProgram
        #if ONTHEMOVE
            userProgram = "OTM"
        #endif
        
        return dict["\(URConstant.Key.COUNTRY_PROGRAM_CHANNEL)\(userProgram)"] as? String
    }
    
    //MARK: On The Move
    class func getOtmProgram() -> URCountryProgram {
        if countryProgram == nil {
            var resource: String!
            switch AppDelegate.environment {
            case .sandbox:
                resource = "countryprogramotm-dev"
            case .production:
                resource = "countryprogramotm"
            }
            let path = Bundle.main.path(forResource: resource, ofType: "json")!
            let data = NSData(contentsOfFile: path)
            let rootJSON = try! JSONSerialization.jsonObject(with: data! as Data) as! [String: Any]
            let countriesJSON = rootJSON["countries"] as! [[String: Any?]]
            countryProgram = URCountryProgram(dictionary: countriesJSON[0])
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
        } else {
            return filtered[0] as URCountryProgram
        }
    }

    class func getAvailableCountryPrograms() -> [URCountryProgram]{
        
        #if ONTHEMOVE
            return [getOtmProgram()]
        #else
            if countryPrograms == nil {
                countryPrograms = []
                let path = Bundle.main.path(forResource: "countryprogram", ofType: "json")!
                let data = NSData(contentsOfFile: path)
                let rootJSON = try! JSONSerialization.jsonObject(with: data! as Data) as! [String: Any]
                let countriesJSON = rootJSON["countries"] as! [[String: Any?]]
                
                for countryJSON in countriesJSON {
                    countryPrograms.append(URCountryProgram(dictionary: countryJSON))
                }
            }
            return countryPrograms
        #endif        
    }

    class func getChannelOfCountryProgram(_ countryProgram:URCountryProgram) -> String?{
        var myDict: NSDictionary?
        var channel:String?
        if let path = Bundle.main.path(forResource: URFireBaseManager.Properties, ofType: "plist") {
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

    class func getUReportApiToken() -> String {
        var rootDictionary: NSDictionary?
        var apiToken = ""
        if let path = Bundle.main.path(forResource: URFireBaseManager.Properties, ofType: "plist") {
            rootDictionary = NSDictionary(contentsOfFile: path)
        }
        if let dict = rootDictionary {
            if dict["\(URConstant.Key.UREPORT_API_TOKEN)"] != nil {
                apiToken = dict["\(URConstant.Key.UREPORT_API_TOKEN)"] as! String
            }
        }
        return apiToken
    }

    class func getChannelOfCurrentCountryProgram() -> String {
        return URCountryProgramManager.getChannelOfCountryProgram(URCountryProgramManager.activeCountryProgram()!)!
    }

    class func activeCountryProgram() -> URCountryProgram? {
        var countryProgram: URCountryProgram?
        
        if let switchProgram = URCountryProgramManager.activeSwitchCountryProgram() {
             countryProgram = switchProgram
        } else if let countryProgramString = UserDefaults.standard.getArchivedObject(key: "countryProgram") as? String {
            countryProgram = URCountryProgram(JSONString: countryProgramString)
        } else {
            countryProgram = URCountryProgramManager.getAvailableCountryPrograms()[0]
        }
        return countryProgram
    }

    class func setActiveCountryProgram(_ countryProgram: URCountryProgram!) {
        self.deactivateCountryProgram()
        UserDefaults.standard.setAsString(object: countryProgram, key: "countryProgram")
    }

    class func deactivateCountryProgram() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: "countryProgram")
        defaults.synchronize()
    }

    class func setSwitchActiveCountryProgram(_ countryProgram: URCountryProgram!) {
        self.deactivateSwitchCountryProgram()
        UserDefaults.standard.setAsString(object: countryProgram, key: "countryProgram_switch")
    }

    class func deactivateSwitchCountryProgram() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: "countryProgram_switch")
        defaults.synchronize()
    }

    class func activeSwitchCountryProgram() -> URCountryProgram? {
        var switchProgram: URCountryProgram?
        if let switchString = UserDefaults.standard.getArchivedObject(key: "countryProgram_switch") as? String {
            switchProgram = URCountryProgram(JSONString: switchString)
        }
        return switchProgram
    }
}

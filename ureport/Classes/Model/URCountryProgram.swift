//
//  URCountryProgram.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URCountryProgram: Mappable {

    var code: String!
    var themeColor: UIColor!
    var name: String!
    var org: NSNumber?
    var rapidProHostHandler: String!
    var rapidProHostAPI: String!
    var ureportHostAPI: String!
    var twitter: String?
    var facebook: String?
    var groupName: String!
    var stateField: String?

    required init?(map: Map) { }
    
    func mapping(map: Map) {
        code <- map["code"]
        themeColor <- (map["themeColor"], HexColorTransform())
        name <- map["name"]
        org <- map["org"]
        rapidProHostHandler <- map["rapidProHostHandler"]
        rapidProHostAPI <- map["rapidProHostAPI"]
        ureportHostAPI <- map["ureportHostAPI"]
        twitter <- map["twitter"]
        facebook <- map["facebook"]
        groupName <- map["groupName"]
        stateField <- map["stateField"]
    }
    
    init(dictionary: [String: Any?]) {
        self.code = dictionary["code"] as! String
        self.themeColor = UIColor(rgba: dictionary["themeColor"] as! String)
        self.org = dictionary["org"] as? NSNumber
        self.name = dictionary["name"] as! String
        self.twitter = dictionary["twitter"] as? String
        self.facebook = dictionary["facebook"] as? String
        self.rapidProHostHandler = "\(dictionary["rapidProHostAPI"] as! String)\(URConstant.RapidPro.HANDLER_SUFIX)"
        self.rapidProHostAPI = "\(dictionary["rapidProHostAPI"] as! String)\(URConstant.RapidPro.API_SUFIX)"
        self.ureportHostAPI = dictionary["ureportHostAPI"] as! String
        self.groupName = dictionary["groupName"] as! String
        self.stateField = dictionary["stateField"] as? String
    }

    //MARK: FireBase Methods
    class func path() -> String {
        return "country_program"
    }
    
}

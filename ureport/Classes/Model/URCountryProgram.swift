//
//  URCountryProgram.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URCountryProgram: Serializable {

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

    init(dictionary: [String: Any?]) {
        self.code = dictionary["code"] as! String
        self.themeColor = UIColor(rgba: dictionary["themeColor"] as! String)
        self.org = dictionary["org"] as? NSNumber
        self.name = dictionary["name"] as! String
        self.twitter = dictionary["twitter"] as? String
        self.facebook = dictionary["facebook"] as? String
        self.rapidProHostHandler = "\(dictionary["rapidProHost"] as! String)\(URConstant.RapidPro.HANDLER_SUFIX)"
        self.rapidProHostAPI = "\(dictionary["rapidProHost"] as! String)\(URConstant.RapidPro.API_SUFIX)"
        self.ureportHostAPI = dictionary["ureportHostAPI"] as! String
        self.groupName = dictionary["groupName"] as! String
        self.stateField = dictionary["stateField"] as? String
        super.init()
    }

    override init () {
        super.init()
    }

    //MARK: FireBase Methods
    class func path() -> String {
        return "country_program"
    }
    
}

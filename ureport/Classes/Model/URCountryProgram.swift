//
//  URCountryProgram.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URCountryProgram: Serializable {
   
    var code:String!
    var themeColor:UIColor?
    var name:String!
    var org:NSNumber?
    var rapidProHostAPI:String!
    var ureportHostAPI:String!
    var twitter:String!
    var facebook:String!
    var groupName:String!
    
    init (code:String!,themeColor:UIColor?,org:NSNumber?,name:String!,twitter:String?,facebook:String?,rapidProHostAPI:String!,ureportHostAPI:String!,groupName:String!) {
        self.code = code
        self.themeColor = themeColor
        self.org = org
        self.name = name
        self.twitter = twitter
        self.facebook = facebook
        self.rapidProHostAPI = rapidProHostAPI
        self.ureportHostAPI = ureportHostAPI
        self.groupName = groupName
    }
    
    override init () {
        super.init()
    }
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "country_program"
    }
    
}

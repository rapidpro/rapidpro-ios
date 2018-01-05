//
//  URStory.swift
//  ureport
//
//  Created by Daniel Amaral on 14/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URStory: Mappable {
    
    var key:String?
    var title:String!
    var content:String!
    var createdDate:NSNumber!
    var user:String!
    var contributions:NSNumber!
    var markers:String?
    var cover:URMedia?
    var medias:[URMedia]?
    var userObject:URUser?
    var like:NSNumber?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        key <- map["key"]
        title <- map["title"]
        content <- map["content"]
        createdDate <- map["createdDate"]
        user <- map["user"]
        contributions <- map["contributions"]
        markers <- map["markers"]
        cover <- map["cover"]
        medias <- map["medias"]
        userObject <- map["userObject"]
        like <- map["like"]
    }
}

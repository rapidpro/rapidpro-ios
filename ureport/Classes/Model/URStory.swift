//
//  URStory.swift
//  ureport
//
//  Created by Daniel Amaral on 14/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URStory: Serializable {
    
    var key:String!
    var title:String!
    var content:String!
    var createdDate:NSNumber!
    var user:String!
    var contributions:NSNumber!
    var markers:String!
    var cover:URMedia!
    var medias:[URMedia]!
    var userObject:URUser?
    var like:NSNumber!
    
}
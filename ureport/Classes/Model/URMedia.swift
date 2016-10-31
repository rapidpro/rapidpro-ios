//
//  URPicture.swift
//  ureport
//
//  Created by Daniel Amaral on 31/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URMedia: Serializable {

    var id:String?
    var url:String!
    var type:String!
    var thumbnail:String?
    var isCover:Bool?
    var metadata:[String:AnyObject]?
    
}

//
//  ISModel.swift
//  TimeDePrimeira
//
//  Created by Daniel Amaral on 28/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

enum URMenuItem:String {
    case Main = "Main"
    case About = "About"
    case Moderation = "Moderation"
    case Settings = "Settings"
}

class ISMenu: NSObject {
    
    var title:String?
    var subtitle:String?
    var menuItem:URMenuItem!
    
}
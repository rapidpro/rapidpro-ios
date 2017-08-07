//
//  ISModel.swift
//  TimeDePrimeira
//
//  Created by Daniel Amaral on 28/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

enum URMenuItem:String {
    case Main = "main_menu_home"
    case About = "label_about_ureport"
    case Moderation = "label_moderation"
    case Settings = "label_settings"
    case Logout = "Logout"
}

class ISMenu {
    
    var title:String?
    var subtitle:String?
    var menuItem:URMenuItem!
    
}

//
//  URMarker.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URMarker: Serializable {
   
    var name:String!
    
    init(name:String){
        self.name = name
    }
    
    convenience init(jsonDict: NSDictionary?) {
        self.init(name: "")
        
        if let jsonDict = jsonDict {
            for (key, value) in jsonDict {
                self.setValue(value, forKey:key as! String)
            }
        }
        
    }
    
    override var description: String {
        print(self.name)
        return self.name
    }
    
}

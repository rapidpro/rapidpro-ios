//
//  UserDefaultsExtension.swift
//  ureport
//
//  Created by Yves Bastos on 05/01/2018.
//  Copyright © 2018 ilhasoft. All rights reserved.
//

import Foundation
import ObjectMapper

extension UserDefaults {
    func getArchivedObject(key: String) -> Any? {
        var any: Any?
        if let encodedData = self.object(forKey: key) as? Data {
            any = NSKeyedUnarchiver.unarchiveObject(with: encodedData)
        }
        return any
    }
    
    func setAsString(object: Mappable, key: String) {
        guard let JSONString = object.toJSONString() else { return }
        
        let encodedObject = NSKeyedArchiver.archivedData(withRootObject: JSONString)
        self.set(encodedObject, forKey: key)
        self.synchronize()
    }
    
    func setAsStringArray(objects: [Mappable], key: String) {
        var array: [String] = []
    
        for object in objects {
            if let JSONString = object.toJSONString() {
                array.append(JSONString)
            }
        }
        
        guard array.count > 0 else {
            return
        }
        
        let encodedObject = NSKeyedArchiver.archivedData(withRootObject: array)
        self.set(encodedObject, forKey: key)
        self.synchronize()
    }
}

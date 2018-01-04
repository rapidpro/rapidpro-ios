//
//  BaseMappableExtension.swift
//  ureport
//
//  Created by Yves Bastos on 04/01/2018.
//  Copyright © 2018 ilhasoft. All rights reserved.
//

import Foundation
import ObjectMapper
import Firebase

extension BaseMappable {
    static var firebaseIdKey: String {
        get {
            return "key"
        }
    }
    
    
    init?(snapshot: DataSnapshot) {
        guard var json = snapshot.value as? [String: Any] else {
            return nil
        }
        
        json[Self.firebaseIdKey] = snapshot.key as Any
        
        self.init(JSON: json)
    }
}


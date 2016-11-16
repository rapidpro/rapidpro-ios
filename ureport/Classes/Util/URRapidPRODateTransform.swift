//
//  RapidPRODateTransformer.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import ObjectMapper

class URRapidPRODateTransform: DateTransform {
    
    override func transformFromJSON(_ value: Any?) -> Date? {
        if let timeInt = value as? Double {
            return Date(timeIntervalSince1970: TimeInterval(timeInt))
        } else if let timeString = value as? String {
            return URDateUtil.dateParserRapidPro(timeString)
        }
        return nil
    }

}

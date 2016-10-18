//
//  URIPCheckManager.swift
//  ureport
//
//  Created by Daniel Amaral on 14/10/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire

class URIPCheckManager: NSObject {

    static var countryCode:String?
    static let syriaCountryCode = "SI"
    
    class func getCountryCodeByIP(completion:(String?) -> Void) {
        Alamofire.request(.GET, "http://ip-api.com/json", parameters: nil, encoding: .JSON, headers: nil).responseJSON { (response:Response<AnyObject, NSError>) in
            if let response = response.result.value {
                if let countryCode = response.objectForKey("countryCode") as? String {
                    self.countryCode = countryCode
                    completion(countryCode)
                }
            }else{
                completion(nil)
            }
        }
        
    }
    
}

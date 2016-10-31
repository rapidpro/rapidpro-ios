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
    static let syriaCountryCode = "SY"
    
    class func getCountryCodeByIP(_ completion:@escaping (String?) -> Void) {
        Alamofire.request("http://ip-api.com/json", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            if let response = response.result.value {
                if let countryCode = (response as AnyObject).object(forKey:"countryCode") as? String {
                    self.countryCode = countryCode
                    completion(countryCode)
                }
            }else{
                completion(nil)
            }
        }
        
    }
    
}

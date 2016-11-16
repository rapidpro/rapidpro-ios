//
//  URGeonamesAPI.swift
//  ureport
//
//  Created by Daniel Amaral on 03/11/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire

class URGeonamesAPI: NSObject {

    static func getGeonameID(countryCode:String, completion:@escaping (_ geonameID:Int?) -> Void ) -> Void {
        Alamofire.request("http://api.geonames.org/countryInfoJSON?country=\(countryCode)&username=ureport", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (response: DataResponse<Any>) in
            
            if let response = (response.result.value as? NSDictionary)?["geonames"] as? [NSDictionary]{
                
                if let geonameId = response[0].object(forKey: "geonameId") as? Int {
                    completion(geonameId)
                }else {
                    completion(nil)
                }
                
            }
            
        })
    }
    
    static func getStatesByGeonameID(geonameId:Int,completion:@escaping (_ states:[URState]?) -> Void ) -> Void {
        
        Alamofire.request("http://api.geonames.org/childrenJSON?geonameId=\(geonameId)&username=ureport").responseJSON(completionHandler: { (response: DataResponse<Any>) in
            
            var states = [URState]()
            
            if let response = response.result.value as? NSDictionary {
                if response["geonames"] != nil && response["totalResultsCount"] as! Int > 0 {
                    for geoname in response["geonames"] as! [NSDictionary] {
                        let state = URState(name: geoname["adminName1"] as! String, boundary: nil)
                        states.append(state)
                    }
                    
                    states = states.sorted{($0.name < $1.name)}
                    completion(states)
                    
                }else {
                    completion(nil)
                }
                
            }else {
                completion(nil)
            }
        })
        
    }
    
}

//
//  URCountryProgramAPI.swift
//  ureport
//
//  Created by Dielson Sales on 26/07/17.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire

struct URCountryProgramResponse {
    let token: String
}

class URCountryProgramAPI {

    private static var cachedCountryProgram: URCountryProgramResponse?

    static func getCountryProgram(countryCode: String, _ completion: @escaping (URCountryProgramResponse?) -> Void) {
        if let cachedCountryProgram = URCountryProgramAPI.cachedCountryProgram {
            completion(cachedCountryProgram)
            return
        }

        Alamofire.request("http://ureportapp.ilhasoft.mobi/api/v2/authentication/\(countryCode)/", headers: ["Authorization": URCountryProgramManager.getUReportApiToken()]).responseJSON { (response: DataResponse<Any>) in
            if let response = response.result.value as? [String: Any] {
                if let token = response["token"] as? String {
                    let result = URCountryProgramResponse(token: token)
                    URCountryProgramAPI.cachedCountryProgram = result
                    completion(result)
                    return
                }
            }
            completion(nil)
        }
    }
}

//
//  URDownloader.swift
//  ureport
//
//  Created by Daniel Amaral on 24/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URDownloader: NSObject {

    class func download(_ URL: Foundation.URL, completion:@escaping (_ data:Data?) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(url: URL)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                print((response as! HTTPURLResponse).statusCode)
                completion(data: data!)
            } else {
                print("Faulure: %@", error!.localizedDescription);
                completion(data: nil)
            }
        }) 
        task.resume()
    }
    
}

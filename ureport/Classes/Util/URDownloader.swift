//
//  URDownloader.swift
//  ureport
//
//  Created by Daniel Amaral on 24/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URDownloader: NSObject {

    class func download(URL: NSURL, completion:(data:NSData?) -> Void) {
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                print((response as! NSHTTPURLResponse).statusCode)
                completion(data: data!)
            } else {
                print("Faulure: %@", error!.localizedDescription);
                completion(data: nil)
            }
        }
        task.resume()
    }
    
}

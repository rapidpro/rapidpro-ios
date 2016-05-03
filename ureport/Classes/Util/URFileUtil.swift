//
//  URFileUtil.swift
//  ureport
//
//  Created by Daniel Amaral on 18/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URFileUtil: NSObject {

    static let outPutURLDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as NSString
    
    class func removeFile(fileURL: NSURL) {
        let filePath = fileURL.path
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(filePath!) {
            do {
                try fileManager.removeItemAtPath(filePath!)
            }catch let error as NSError {
                print("Can't remove file \(error.localizedDescription)")
            }
            
        }else{
            print("file doesn't exist")
        }
    }
    
    class func writeFile(data:NSData) -> String{
        
        let path = URFileUtil.outPutURLDirectory.stringByAppendingPathComponent("audio.3gp")
        
        URFileUtil.removeFile(NSURL(string: path)!)
        
        if data.writeToFile(path, atomically: true) == true {
            print("file available")
        }
        
        return path
    }
    
}

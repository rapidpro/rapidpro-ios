//
//  URFileUtil.swift
//  ureport
//
//  Created by Daniel Amaral on 18/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URFileUtil: NSObject {

    static let outPutURLDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
    
    class func removeFile(_ fileURL: URL) {
        let filePath = fileURL.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            }catch let error as NSError {
                print("Can't remove file \(error.localizedDescription)")
            }
            
        }else{
            print("file doesn't exist")
        }
    }
    
    class func writeFile(_ data:Data) -> String{
        
        let path = URFileUtil.outPutURLDirectory.appendingPathComponent("audio.3gp")
        
        URFileUtil.removeFile(URL(string: path)!)
        
        if ((try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil) == true {
            print("file available")
        }
        
        return path
    }
    
}

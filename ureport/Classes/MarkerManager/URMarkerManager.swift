//
//  URMarkerManager.swift
//  ureport
//
//  Created by Daniel Amaral on 14/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URMarkerManager: Serializable {
   
    static var markers:[URMarker]!
    
    class func getMarkers() -> [URMarker]{
        
        if markers == nil {
            markers = []
            markers.append(URMarker(name: "Advocacy"))
            markers.append(URMarker(name: "Child Protection"))
            markers.append(URMarker(name: "Education"))
            markers.append(URMarker(name: "Health"))
            markers.append(URMarker(name: "HIV/AIDS"))
            markers.append(URMarker(name: "Nutrition"))
            markers.append(URMarker(name: "Politics"))
            markers.append(URMarker(name: "Social Policy"))
            markers.append(URMarker(name: "Sanitation"))
            markers.append(URMarker(name: "Violence"))
        }
        
        if !URMarkerManager.getLocalyMarkers().isEmpty {

            for marker in URMarkerManager.getLocalyMarkers() {
                let markerObject = URMarker(jsonDict: marker)
                markers.append(markerObject)
            }
            
        }
        
        return markers
        
    }
    
    class func saveMarker(marker:URMarker) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var markerDic:[NSDictionary] = URMarkerManager.getLocalyMarkers()
        
        if let _ = markerDic.indexOf(marker.toDictionary()) {
            return
        }else {
            markerDic.append(marker.toDictionary())
        }
        
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(markerDic), forKey: "markers")
        defaults.synchronize()
    }
    
    class func getLocalyMarkers() -> [NSDictionary]{
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let markerDic:[NSDictionary] = []
        
        if let markers = defaults.objectForKey("markers") as? NSData {
            return (NSKeyedUnarchiver.unarchiveObjectWithData(markers)) as! [NSDictionary]
        }
        
        return markerDic
    }
    
}

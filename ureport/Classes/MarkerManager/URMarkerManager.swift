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
            markers.append(URMarker(name: "Advocacy".localized))
            markers.append(URMarker(name: "Child Protection".localized))
            markers.append(URMarker(name: "Education".localized))
            markers.append(URMarker(name: "Emergency".localized))
            markers.append(URMarker(name: "Health".localized))
            markers.append(URMarker(name: "HIV/AIDS".localized))
            markers.append(URMarker(name: "Nutrition".localized))
            markers.append(URMarker(name: "Politics".localized))
            markers.append(URMarker(name: "Social Policy".localized))
            markers.append(URMarker(name: "Sanitation".localized))
            markers.append(URMarker(name: "Violence".localized))
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

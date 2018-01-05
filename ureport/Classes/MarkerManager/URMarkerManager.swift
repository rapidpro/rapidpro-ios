//
//  URMarkerManager.swift
//  ureport
//
//  Created by Daniel Amaral on 14/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URMarkerManager {
   
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
        
        let localMarkers = URMarkerManager.getLocalyMarkers()
        markers.append(contentsOf: localMarkers)
        return markers
    }
    
    class func saveMarker(_ marker:URMarker) {
        var markers = URMarkerManager.getLocalyMarkers()
        
        guard markers.index(where: {$0.name == marker.name}) == nil else {
            return
        }
        
        markers.append(marker)
        UserDefaults.standard.setAsStringArray(objects: markers, key: "markers")
    }
    
    class func getLocalyMarkers() -> [URMarker] {
        var markersArray: [URMarker] = []
        if let markersStrings = UserDefaults.standard.getArchivedObject(key: "markers") as? [String] {
            for markerString in markersStrings {
                if let marker = URMarker(JSONString: markerString) {
                    markersArray.append(marker)
                }
            }
        }
        return markersArray
    }
}

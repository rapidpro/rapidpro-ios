//
//  URPollManager.swift
//  ureport
//
//  Created by Daniel Amaral on 22/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

protocol URPollManagerDelegate {
    func newPollReceived(poll:URPoll)
    func newPollResultReceived(pollResult:URPollResult)
}

class URPollManager: NSObject {

    var delegate:URPollManagerDelegate?
    var pollIndex = 0
    
    static var colors:[String] = []
    static var categoryAndColorList:[NSDictionary] = []
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "poll"
    }
    
    class func pathForPollResult() -> String {
        return "poll_result"
    }
    
    func getPolls() {
        
        pollIndex = 0
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URPollManager.path())
            .observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
                if let delegate = self.delegate {
                    
                    let poll = URPoll(jsonDict: snapshot.value as? NSDictionary)
                    let category = URPollCategory(jsonDict: (snapshot.value as! NSDictionary).objectForKey("category")! as? NSDictionary)
                    
                    category.color = URPollManager.getAvailableColorToCategory(category, index: self.pollIndex)
                    
                    poll.key = snapshot.key
                    poll.category = category
                    delegate.newPollReceived(poll)
                    
                    self.pollIndex += 1
                }
            })
    }
    
    func getPollsResults(pollKey:String!) {
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URPollManager.pathForPollResult())
            .childByAppendingPath(pollKey)
            .observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
                if let delegate = self.delegate {
                    
                    let pollResult = URPollResult(jsonDict: snapshot.value as? NSDictionary)
                    
                    if let results = (snapshot.value as? NSDictionary)!.objectForKey("results") {
                        pollResult.results = results as! [NSDictionary]
                    }
                    
                    delegate.newPollResultReceived(pollResult)
                    
                }
            })
    }
 
    class func getAvailableColorToCategory(pollCategory:URPollCategory,index:Int) -> UIColor {
        
        let filtered = categoryAndColorList.filter {
            if $0.objectForKey(pollCategory.name) != nil {
                return true
            }else {
                return false
            }
        }
        
        if !filtered.isEmpty {
            return UIColor(rgba: filtered[0].objectForKey(pollCategory.name) as! String)
        }else {
            var index = index
            if index >= URPollManager.getColors().count {
                index = Int(arc4random_uniform(UInt32(self.colors.count)))
            }
            categoryAndColorList.append([pollCategory.name:URPollManager.getColors()[index]])
            return UIColor(rgba: URPollManager.getColors()[index] as String)
        }
        
    }
    
    class func getColors() -> [String]{
        
        if colors.isEmpty {
            colors.append("#78c95d")
            colors.append("#b08f6d")
            colors.append("#db3d38")
            colors.append("#9896a3")
            colors.append("#9adddd")
            colors.append("#f7c052")
            colors.append("#134e82")
            colors.append("#93a8ce")
            colors.append("#f5766e")
            colors.append("#f6caca")
        }
        
        return colors
    }
    
}

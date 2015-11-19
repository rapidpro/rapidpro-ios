//
//  URContributionManager.swift
//  ureport
//
//  Created by Daniel Amaral on 16/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URContributionManagerDelegate {
    func newContributionReceived(contribution:URContribution)
}

class URContributionManager: NSObject {
   
    var delegate:URContributionManagerDelegate?
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "contribution"
    }
    
    func getContributions(storyKey:String!) {
                
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URContributionManager.path())
            .childByAppendingPath(storyKey)
            .queryOrderedByChild("createdDate")
            .observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
                if let delegate = self.delegate {
                                        
                    let contribution = URContribution(jsonDict: snapshot.value as? NSDictionary)
                    let author = URUser(jsonDict: (snapshot.value as! NSDictionary).objectForKey("author")! as? NSDictionary)
                    
                    URUserManager.getByKey(author.key, completion: { (user:URUser?, exists:Bool) -> Void in
                        if user != nil {
                            contribution.key = snapshot.key
                            contribution.author = user
                            delegate.newContributionReceived(contribution)
                        }
                    })
                }
            })
        
    }
    
    class func saveContribution(storyKey:String,contribution:URContribution,completion:(Bool!) -> Void) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URContributionManager.path())
            .childByAppendingPath(storyKey)
            .childByAutoId()
            .setValue(contribution.toDictionary(), withCompletionBlock: { (error:NSError!, firebase: Firebase!) -> Void in
                if error != nil {
                    completion(false)
                }else {
                    completion(true)
                }
            })
    }
    
    class func getTotalContributions(storyKey:String,completion:(Int) -> Void) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URContributionManager.path())
            .childByAppendingPath(storyKey)
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    completion(Int(snapshot.childrenCount))
                }else {
                    completion(0)
                }
            })
    }
    
    class func removeContribution(storyKey:String,contributionKey:String) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URContributionManager.path())
            .childByAppendingPath(storyKey)
            .childByAppendingPath(contributionKey)
            .removeValue()
    }
    
}

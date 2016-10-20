//
//  URContributionManager.swift
//  ureport
//
//  Created by Daniel Amaral on 16/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

protocol URContributionManagerDelegate {
    func newContributionReceived(_ contribution:URContribution)
}

class URContributionManager: NSObject {
   
    var delegate:URContributionManagerDelegate?
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "contribution"
    }
    
    class func pathPollContribution() -> String {
        return "poll_contribution"
    }
    
    func getContributions(_ storyKey:String!) {
                
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URContributionManager.path())
            .child(byAppendingPath: storyKey)
            .queryOrdered(byChild: "createdDate")
            .observe(FEventType.childAdded, with: { (snapshot) in
                if let delegate = self.delegate {
                                        
                    let contribution = URContribution(jsonDict: snapshot?.value as? NSDictionary)
                    let author = URUser(jsonDict: (snapshot?.value as! NSDictionary).object(forKey: "author")! as? NSDictionary)
                    
                    URUserManager.getByKey(author.key, completion: { (user:URUser?, exists:Bool) -> Void in
                        if user != nil {
                            contribution.key = snapshot?.key
                            contribution.author = user
                            delegate.newContributionReceived(contribution)
                        }
                    })
                }
            })
        
    }
    
    func getPollContributions(_ pollkey:String!) {
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URContributionManager.pathPollContribution())
            .child(byAppendingPath: pollkey)
            .queryOrdered(byChild: "createdDate")
            .observe(FEventType.childAdded, with: { (snapshot) in
                if let delegate = self.delegate {
                    
                    let contribution = URContribution(jsonDict: snapshot?.value as? NSDictionary)
                    let author = URUser(jsonDict: (snapshot?.value as! NSDictionary).object(forKey: "author")! as? NSDictionary)
                    
                    URUserManager.getByKey(author.key, completion: { (user:URUser?, exists:Bool) -> Void in
                        if user != nil {
                            contribution.key = snapshot?.key
                            contribution.author = user
                            delegate.newContributionReceived(contribution)
                        }
                    })
                }
            })
        
    }
    
    class func saveContribution(_ storyKey:String,contribution:URContribution,completion:@escaping (Bool!) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URContributionManager.path())
            .child(byAppendingPath: storyKey)
            .childByAutoId()
            .setValue(contribution.toDictionary(), withCompletionBlock: { (error:Error?, firebase: Firebase?) -> Void in
                if error != nil {
                    completion(false)
                }else {
                    completion(true)
                }
            })
    }
    
    class func savePollContribution(_ pollKey:String,contribution:URContribution,completion:@escaping (Bool!) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URContributionManager.pathPollContribution())
            .child(byAppendingPath: pollKey)
            .childByAutoId()
            .setValue(contribution.toDictionary(), withCompletionBlock: { (error:Error?, firebase: Firebase?) -> Void in
                if error != nil {
                    completion(false)
                }else {
                    completion(true)
                }
            })
    }
    
    class func getTotalContributions(_ storyKey:String,completion:@escaping (Int) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URContributionManager.path())
            .child(byAppendingPath: storyKey)
            .observeSingleEvent(of: FEventType.value, with: { snapshot in
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    completion(Int((snapshot?.childrenCount)!))
                }else {
                    completion(0)
                }
            })
    }
    
    class func removeContribution(_ storyKey:String,contributionKey:String) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URContributionManager.path())
            .child(byAppendingPath: storyKey)
            .child(byAppendingPath: contributionKey)
            .removeValue()
    }
    
    
    class func removePollContribution(_ pollKey:String,contributionKey:String) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URContributionManager.pathPollContribution())
            .child(byAppendingPath: pollKey)
            .child(byAppendingPath: contributionKey)
            .removeValue()
    }
    
}

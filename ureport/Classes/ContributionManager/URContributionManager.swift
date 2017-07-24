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
    
    func getContributions(_ storyKey: String!) {
                
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URContributionManager.path())
            .child(storyKey)
            .queryOrdered(byChild: "createdDate")
            .observe(.childAdded, with: { snapshot in
                guard let delegate = self.delegate else { return }

                let contribution = URContribution(jsonDict: snapshot.value as? NSDictionary)
                let author = URUser(jsonDict: (snapshot.value as! NSDictionary).object(forKey: "author")! as? NSDictionary)

                URUserManager.getByKey(author.key, completion: { (user, exists) -> Void in
                    guard let user = user else { return }
                    contribution.key = snapshot.key
                    contribution.author = user
                    delegate.newContributionReceived(contribution)
                })
            })
        
    }
    
    func getPollContributions(_ pollkey: String!) {
        
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URContributionManager.pathPollContribution())
            .child(pollkey)
            .queryOrdered(byChild: "createdDate")
            .observe(.childAdded, with: { snapshot in
                guard let delegate = self.delegate else { return }
                let contribution = URContribution(jsonDict: snapshot.value as? NSDictionary)
                let author = URUser(jsonDict: (snapshot.value as! NSDictionary).object(forKey: "author")! as? NSDictionary)
                URUserManager.getByKey(author.key) { (user, exists) -> Void in
                    guard let user = user else { return }
                    contribution.key = snapshot.key
                    contribution.author = user
                    delegate.newContributionReceived(contribution)
                }
            })
        
    }
    
    class func saveContribution(_ storyKey: String, contribution: URContribution, completion: @escaping (Bool!) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URContributionManager.path())
            .child(storyKey)
            .childByAutoId()
            .setValue(contribution.toDictionary(), withCompletionBlock: { (error, _) -> Void in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
    }
    
    class func savePollContribution(_ pollKey: String, contribution: URContribution, completion: @escaping (Bool!) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URContributionManager.pathPollContribution())
            .child(pollKey)
            .childByAutoId()
            .setValue(contribution.toDictionary(), withCompletionBlock: { (error, _) -> Void in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
    }
    
    class func getTotalContributions(_ storyKey: String, completion: @escaping (Int) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URContributionManager.path())
            .child(storyKey)
            .observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.value != nil else {
                    completion(0)
                    return
                }
                completion(Int(snapshot.childrenCount))
            })
    }
    
    class func removeContribution(_ storyKey: String, contributionKey: String) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URContributionManager.path())
            .child(storyKey)
            .child(contributionKey)
            .removeValue()
    }
    
    
    class func removePollContribution(_ pollKey: String, contributionKey: String) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URContributionManager.pathPollContribution())
            .child(pollKey)
            .child(contributionKey)
            .removeValue()
    }
    
}

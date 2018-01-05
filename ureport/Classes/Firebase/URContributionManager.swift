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

class URContributionManager {
   
    var delegate:URContributionManagerDelegate?
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "contribution"
    }
    
    class func pathPollContribution() -> String {
        return "poll_contribution"
    }
    
    class func pathContributionDenounced() -> String {
        return "contribution_denounced"
    }
    
    func getContributions(_ storyKey: String!) {
                
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URContributionManager.path())
            .child(storyKey)
            .queryOrdered(byChild: "createdDate")
            .observe(.childAdded, with: { snapshot in
                guard let delegate = self.delegate, let contribution = URContribution(snapshot: snapshot) else { return }
                
//                let json = (snapshot.value as! NSDictionary).object(forKey: "author")! as? [String: Any] ?? [:]

                URUserManager.getByKey(contribution.author.key, completion: { (user, exists) -> Void in
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
                guard let delegate = self.delegate, let contribution = URContribution(snapshot: snapshot) else { return }
                
//                let json = (snapshot.value as! NSDictionary).object(forKey: "author")! as? [String: Any] ?? [:]
//                guard let author = URUser(JSON: json) else {
//                    return
//                }
                
                URUserManager.getByKey(contribution.author.key) { (user, exists) -> Void in
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
            .setValue(contribution.toJSON(), withCompletionBlock: { (error, _) -> Void in
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
            .setValue(contribution.toJSON(), withCompletionBlock: { (error, _) -> Void in
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
    
    class func getTotalContributions(keys: Set<String>, completion:@escaping (_ storyAndContributions: [String: Int]) -> Void) {
        guard keys.count > 0 else {
            completion([:])
            return
        }
        
        var counter = 0
        
        var keysAndContributions = [String: Int]()
        for key in keys {
            URFireBaseManager.sharedInstance()
                .child(URCountryProgram.path())
                .child(URCountryProgramManager.activeCountryProgram()!.code)
                .child(URContributionManager.path())
                .child(key)
                .observeSingleEvent(of: .value, with: { snapshot in
                    let contributionsLike = Int(snapshot.childrenCount)
                    keysAndContributions[key] = contributionsLike
                    
                    counter += 1
                    if counter == keys.count {
                        completion(keysAndContributions)
                        return
                    }
                })
        }
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
    
    class func setContributionAsDenounced(_ storyKey: String, contribution: URContribution, completion: @escaping (Bool) -> ()) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.pathContributionDenounced())
            .child(storyKey)
            .setValue(contribution.toJSON()) {
                (error, _) in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
        }
    }
}

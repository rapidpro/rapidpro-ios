//
//  URStoryManager.swift
//  ureport
//
//  Created by Daniel Amaral on 13/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

protocol URStoryManagerDelegate {
    func newStoryReceived(_ story:URStory)
}

class URStoryManager: NSObject {
 
    let itensByQuery = 5

    var delegate:URStoryManagerDelegate?
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "story"
    }
    
    class func pathStoryDisapproved() -> String {
        return "story_disapproved"
    }
    
    class func pathStoryModerate() -> String {
        return "story_moderate"
    }
    
    class func pathStoryLike() -> String {
        return "story_like"
    }
    
    func getStories(_ storiesToModerate:Bool, initQueryFromItem:Int) {
                
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: storiesToModerate == true ? URStoryManager.pathStoryModerate() : URStoryManager.path())
            .queryLimited(toLast: UInt(initQueryFromItem + itensByQuery))
            .observe(FEventType.childAdded, with: { (snapshot) in
                if let delegate = self.delegate {
                    
                    let story = URStory(jsonDict: snapshot?.value as? NSDictionary)
                    
                    story.key = snapshot?.key
                    
                    if (snapshot?.value as! NSDictionary).object(forKey: "cover") != nil {
                        let cover = URMedia(jsonDict:((snapshot?.value as! NSDictionary).object(forKey: "cover") as? NSDictionary)!)
                        story.cover = cover
                    }
                    
                    var medias:[URMedia] = []
                    
                    if let mediaArray = (snapshot?.value as! NSDictionary).object(forKey: "medias") as? NSArray {
                        
                        for value in mediaArray {
                            let media = URMedia(jsonDict:value as? NSDictionary)
                            medias.append(media)
                        }
                        
                        story.medias = medias
                    }
                    
                    delegate.newStoryReceived(story)
                    
                }
            })
    }
    
    func getStoriesWithCompletion(_ storiesToModerate:Bool, initQueryFromItem:Int,completion:@escaping (_ storyList:[URStory]) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: storiesToModerate == true ? URStoryManager.pathStoryModerate() : URStoryManager.path())
            .queryLimited(toLast: UInt(initQueryFromItem + itensByQuery))
            .observeSingleEvent(of: FEventType.value, with: { (snapshot) in
                
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    
                    var storyList = [URStory]()
                    
                    for data in snapshot?.children.allObjects as! [FDataSnapshot]{
                        let story = URStory(jsonDict: data.value as? NSDictionary)
                        
                        story.key = data.key
                        
                        if (data.value as! NSDictionary).object(forKey: "cover") != nil {
                            let cover = URMedia(jsonDict:((data.value as! NSDictionary).object(forKey: "cover") as? NSDictionary)!)
                            story.cover = cover
                        }
                        
                        var medias:[URMedia] = []
                        
                        if let mediaArray = (data.value as! NSDictionary).object(forKey: "medias") as? NSArray {
                            
                            for value in mediaArray {
                                let media = URMedia(jsonDict:value as? NSDictionary)
                                medias.append(media)
                            }
                            
                            story.medias = medias
                        }
                        storyList.append(story)
                    }
                    
                    completion(storyList)
                    
                }else {
                    completion([])
                }
                
            })
    }
    
    class func getStoryLikes(_ storyKey:String,completion:@escaping (_ likeCount:Int) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: self.pathStoryLike())
            .child(byAppendingPath: storyKey)
            .observeSingleEvent(of: FEventType.value, with: { snapshot in
                completion(Int((snapshot?.childrenCount)!))
            })
    }
    
    class func checkIfStoryWasLiked(_ storyKey:String,completion:@escaping (_ liked:Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: self.pathStoryLike())
            .child(byAppendingPath: storyKey)
            .child(byAppendingPath: URUser.activeUser()?.key)
            .observeSingleEvent(of: FEventType.value, with: { snapshot in
                completion((snapshot?.exists())!)
            })
    }
    
    class func saveStoryLike(_ key:String) -> Void {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: self.pathStoryLike())
            .child(byAppendingPath: key)
            .setValue([URUser.activeUser()!.key:true])
    }
    
    class func removeStoryLike(_ key:String) -> Void {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: self.pathStoryLike())
            .child(byAppendingPath: key)
            .child(byAppendingPath: URUser.activeUser()!.key)
            .removeValue()
    }
    
    class func saveStory(_ story:URStory,isModerator:Bool, completion:@escaping (Bool) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: isModerator == true ? self.path() : self.pathStoryModerate())
            .childByAutoId()
            .setValue(story.toDictionary(), withCompletionBlock: { (error:Error?, firebase: Firebase?) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                    completion(false)
                }else {
                    URUserManager.incrementUserStories(story.user)
                    completion(true)
                }
            })
    }
 
    class func setStoryAsPublished(_ story:URStory, completion:@escaping (_ finished:Bool) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: story.key)
            .setValue(story.toDictionary(), withCompletionBlock: { (error:Error?, firebase: Firebase?) -> Void in
                completion(true)
                if error != nil {
                    print(error?.localizedDescription)
                }
            })
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: self.pathStoryModerate())
            .child(byAppendingPath: story.key)
            .removeValue()
    }
    
    class func setStoryAsDisapproved(_ story:URStory, completion:@escaping (_ finished:Bool) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: self.pathStoryDisapproved())
            .child(byAppendingPath: story.key)
            .setValue(story.toDictionary(), withCompletionBlock: { (error:Error?, firebase: Firebase?) -> Void in
                completion(finished: true)                
                if error != nil {
                    print(error.localizedDescription)
                }
            })
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: self.pathStoryModerate())
            .child(byAppendingPath: story.key)
            .removeValue()
    }
    
}

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
    func newStoryReceived(story:URStory)
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
    
    func getStories(storiesToModerate:Bool, initQueryFromItem:Int) {
                
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(storiesToModerate == true ? URStoryManager.pathStoryModerate() : URStoryManager.path())
            .queryLimitedToLast(UInt(initQueryFromItem + itensByQuery))
            .observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
                if let delegate = self.delegate {
                    
                    let story = URStory(jsonDict: snapshot.value as? NSDictionary)
                    
                    story.key = snapshot.key
                    
                    if (snapshot.value as! NSDictionary).objectForKey("cover") != nil {
                        let cover = URMedia(jsonDict:((snapshot.value as! NSDictionary).objectForKey("cover") as? NSDictionary)!)
                        story.cover = cover
                    }
                    
                    var medias:[URMedia] = []
                    
                    if let mediaArray = (snapshot.value as! NSDictionary).objectForKey("medias") as? NSArray {
                        
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
    
    func getStoriesWithCompletion(storiesToModerate:Bool, initQueryFromItem:Int,completion:(storyList:[URStory]) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(storiesToModerate == true ? URStoryManager.pathStoryModerate() : URStoryManager.path())
            .queryLimitedToLast(UInt(initQueryFromItem + itensByQuery))
            .observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot) in
                
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    
                    var storyList = [URStory]()
                    
                    for data in snapshot.children.allObjects as! [FDataSnapshot]{
                        let story = URStory(jsonDict: data.value as? NSDictionary)
                        
                        story.key = data.key
                        
                        if (data.value as! NSDictionary).objectForKey("cover") != nil {
                            let cover = URMedia(jsonDict:((data.value as! NSDictionary).objectForKey("cover") as? NSDictionary)!)
                            story.cover = cover
                        }
                        
                        var medias:[URMedia] = []
                        
                        if let mediaArray = (data.value as! NSDictionary).objectForKey("medias") as? NSArray {
                            
                            for value in mediaArray {
                                let media = URMedia(jsonDict:value as? NSDictionary)
                                medias.append(media)
                            }
                            
                            story.medias = medias
                        }
                        storyList.append(story)
                    }
                    
                    completion(storyList: storyList)
                    
                }else {
                    completion(storyList: [])
                }
                
            })
    }
    
    class func getStoryLikes(storyKey:String,completion:(likeCount:Int) -> Void) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.pathStoryLike())
            .childByAppendingPath(storyKey)
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                completion(likeCount: Int(snapshot.childrenCount))
            })
    }
    
    class func checkIfStoryWasLiked(storyKey:String,completion:(liked:Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.pathStoryLike())
            .childByAppendingPath(storyKey)
            .childByAppendingPath(URUser.activeUser()?.key)
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                completion(liked: snapshot.exists())
            })
    }
    
    class func saveStoryLike(key:String) -> Void {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.pathStoryLike())
            .childByAppendingPath(key)
            .setValue([URUser.activeUser()!.key:true])
    }
    
    class func removeStoryLike(key:String) -> Void {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.pathStoryLike())
            .childByAppendingPath(key)
            .childByAppendingPath(URUser.activeUser()!.key)
            .removeValue()
    }
    
    class func saveStory(story:URStory,isModerator:Bool, completion:(Bool) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(isModerator == true ? self.path() : self.pathStoryModerate())
            .childByAutoId()
            .setValue(story.toDictionary(), withCompletionBlock: { (error:NSError!, firebase: Firebase!) -> Void in
                if error != nil {
                    print(error.localizedDescription)
                    completion(false)
                }else {
                    URUserManager.incrementUserStories(story.user)
                    completion(true)
                }
            })
    }
 
    class func setStoryAsPublished(story:URStory, completion:(finished:Bool) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.path())
            .childByAppendingPath(story.key)
            .setValue(story.toDictionary(), withCompletionBlock: { (error:NSError!, firebase: Firebase!) -> Void in
                completion(finished: true)
                if error != nil {
                    print(error.localizedDescription)
                }
            })
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.pathStoryModerate())
            .childByAppendingPath(story.key)
            .removeValue()
    }
    
    class func setStoryAsDisapproved(story:URStory, completion:(finished:Bool) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.pathStoryDisapproved())
            .childByAppendingPath(story.key)
            .setValue(story.toDictionary(), withCompletionBlock: { (error:NSError!, firebase: Firebase!) -> Void in
                completion(finished: true)                
                if error != nil {
                    print(error.localizedDescription)
                }
            })
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.pathStoryModerate())
            .childByAppendingPath(story.key)
            .removeValue()
    }
    
}

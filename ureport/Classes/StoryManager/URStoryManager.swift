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

class URStoryManager {
 
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
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(storiesToModerate == true ? URStoryManager.pathStoryModerate() : URStoryManager.path())
            .queryLimited(toLast: UInt(initQueryFromItem + itensByQuery))
            .observe(.childAdded, with: { (snapshot) in
                if let delegate = self.delegate {
                    
                    let story = URStory(jsonDict: snapshot.value as? NSDictionary)
                    
                    story.key = snapshot.key
                    
                    if (snapshot.value as! NSDictionary).object(forKey: "cover") != nil {
                        let cover = URMedia(jsonDict:((snapshot.value as! NSDictionary).object(forKey: "cover") as? NSDictionary)!)
                        story.cover = cover
                    }
                    
                    var medias:[URMedia] = []
                    
                    if let mediaArray = (snapshot.value as! NSDictionary).object(forKey: "medias") as? NSArray {
                        
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
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(storiesToModerate == true ? URStoryManager.pathStoryModerate() : URStoryManager.path())
            .queryLimited(toLast: UInt(initQueryFromItem + itensByQuery))
            .observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.value != nil else {
                    completion([])
                    return
                }
                var storyList = [URStory]()
                for data in snapshot.children.allObjects as! [DataSnapshot]{
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
            })
    }
    
    class func getStoryLikes(_ storyKey:String,completion:@escaping (_ likeCount:Int) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.pathStoryLike())
            .child(storyKey)
            .observeSingleEvent(of: .value, with: { snapshot in
                completion(Int(snapshot.childrenCount))
            })
    }
    
    class func checkIfStoryWasLiked(_ storyKey:String, completion:@escaping (_ liked:Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.pathStoryLike())
            .child(storyKey)
            .child(URUser.activeUser()!.key)
            .observeSingleEvent(of: .value, with: { snapshot in
                completion(snapshot.exists())
            })
    }
    
    class func saveStoryLike(_ key:String) -> Void {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.pathStoryLike())
            .child(key)
            .setValue([URUser.activeUser()!.key:true])
    }
    
    class func removeStoryLike(_ key:String) -> Void {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.pathStoryLike())
            .child(key)
            .child(URUser.activeUser()!.key)
            .removeValue()
    }
    
    class func saveStory(_ story:URStory,isModerator:Bool, completion:@escaping (Bool) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(isModerator == true ? self.path() : self.pathStoryModerate())
            .childByAutoId()
            .setValue(story.toDictionary(), withCompletionBlock: { (error, _) -> Void in
                guard error == nil else {
                    print(error!.localizedDescription)
                    completion(false)
                    return
                }
                URUserManager.incrementUserStories(story.user)
                completion(true)
            })
    }
 
    class func setStoryAsPublished(_ story:URStory, completion:@escaping (_ finished:Bool) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.path())
            .child(story.key!)
            .setValue(story.toDictionary(), withCompletionBlock: { (error, _) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                completion(true)
            })
        
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.pathStoryModerate())
            .child(story.key!)
            .removeValue()
    }
    
    class func setStoryAsDisapproved(_ story:URStory, completion:@escaping (_ finished:Bool) -> Void) {

        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.pathStoryDisapproved())
            .child(story.key!)
            .setValue(story.toDictionary(), withCompletionBlock: { (error, _) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                completion(true)
            })

        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.pathStoryModerate())
            .child(story.key!)
            .removeValue()
    }
}

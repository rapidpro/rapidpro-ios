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
    
    func getStories(storiesToModerate:Bool) {
                
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(storiesToModerate == true ? URStoryManager.pathStoryModerate() : URStoryManager.path())
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
                        
                        delegate.newStoryReceived(story)                        
                    }                    
                }
            })
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

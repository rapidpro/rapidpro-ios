//
//  URModalProfileViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 30/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URModalProfileViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var lbNickName: UILabel!
    @IBOutlet weak var lbStories: UILabel!
    @IBOutlet weak var lbStoriesValue: UILabel!
    @IBOutlet weak var lbPolls: UILabel!
    @IBOutlet weak var lbPollsValue: UILabel!
    @IBOutlet weak var lbPoints: UILabel!
    @IBOutlet weak var lbPointsValue: UILabel!
    @IBOutlet weak var lbContributions: UILabel!
    @IBOutlet weak var btInviteToChat: UIButton!
    @IBOutlet weak var imageProfile: UIImageView!    
    @IBOutlet weak var btClose: UIButton!
    
    var user:URUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundView.layer.cornerRadius = 5
        self.btInviteToChat.layer.cornerRadius = 4
        
        setupUserInfo()
        setupLayout()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Modal Profile")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
    }

    init(user:URUser) {
        self.user = user
        super.init(nibName: "URModalProfileViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Class Methods
    
    func setupLayout() {
        self.lbPoints.text = "label_view_points".localized
        self.lbStories.text = "main_stories".localized
        self.lbPolls.text = "main_polls".localized
    }
    
    func setupUserInfo() {
        self.lbNickName.text = user.nickname
        
        if let contributions = user.contributions {
            self.lbContributions.text! = String(format: "stories_list_item_contributions".localized, arguments: [Int(contributions)])
        }
        
        if let points = user.points {
            self.lbPointsValue.text! = "\(Int(points))"
        }
        
        if let stories = user.stories {
            self.lbStoriesValue.text! = "\(Int(stories))"
        }
        
        self.roundedView.layer.borderWidth = 2
        self.roundedView.layer.borderColor = UIColor.whiteColor().CGColor
        
        if let picture = user.picture {
            self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            self.imageProfile.contentMode = UIViewContentMode.ScaleAspectFit
            self.imageProfile.sd_setImageWithURL(NSURL(string: picture))
        }else{
            self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            self.imageProfile.contentMode = UIViewContentMode.Center
            self.imageProfile.image = UIImage(named: "ic_person")
        }
        
        if self.user.key! == URUser.activeUser()!.key {
            self.btInviteToChat.hidden = true
        }else{
            self.btInviteToChat.hidden = false
        }
        
    }
    
    func close() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.backgroundColor = self.view.backgroundColor?.colorWithAlphaComponent(0)
            }) { (finished) -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName("modalProfileDidClosed", object: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    //MARK: Button Events
    
    @IBAction func btInviteToChatTapped(sender: AnyObject) {
        
        URUserManager.getByKey(self.user.key) { (user, exists) -> Void in
            if let chatRooms = user!.chatRooms {
                for chatRoomKey in chatRooms.allKeys {
                    
                    let filtered = user!.chatRooms.filter {
                        return $0.key as! String == chatRoomKey as! String
                    }
                    
                    if !filtered.isEmpty {
                        URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoomKey as! String, completionWithUsers: { (users:[URUser]) -> Void in
                            URChatRoomManager.getByKey(chatRoomKey as! String, completion: { (chatRoom) -> Void in
                                self.dismissViewControllerAnimated(true, completion: nil)
                                URNavigationManager.navigation.pushViewController(URMessagesViewController(chatRoom: chatRoom,chatMembers:users,title:user!.nickname),animated:true)
                            })
                        })
                    }else {
                        ProgressHUD.show(nil)
                        URChatRoomManager.createIndividualChatRoom(user!, completion: { (chatRoom, chatMembers, title) -> Void in
                            ProgressHUD.dismiss()
                            self.dismissViewControllerAnimated(true, completion: nil)
                            URNavigationManager.navigation.pushViewController(URMessagesViewController(chatRoom: chatRoom,chatMembers:chatMembers,title:title),animated:true)
                        })
                    }
                    
                }
            }else {
                ProgressHUD.show(nil)
                URChatRoomManager.createIndividualChatRoom(user!, completion: { (chatRoom, chatMembers, title) -> Void in
                    ProgressHUD.dismiss()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    URNavigationManager.navigation.pushViewController(URMessagesViewController(chatRoom: chatRoom,chatMembers:chatMembers,title:title),animated:true)
                })
            }
        }
        
    }
    
    @IBAction func btCloseTapped(sender: AnyObject) {
        self.close()
    }
    
}

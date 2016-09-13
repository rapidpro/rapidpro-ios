//
//  URModalProfileViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 30/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import MBProgressHUD

class URModalProfileViewController: UIViewController, URChatRoomManagerDelegate {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var lbNickName: UILabel!
    @IBOutlet weak var lbStories: UILabel!
    @IBOutlet weak var lbStoriesValue: UILabel!
    @IBOutlet weak var lbPoints: UILabel!
    @IBOutlet weak var lbPointsValue: UILabel!
    @IBOutlet weak var lbContributions: UILabel!
    @IBOutlet weak var btInviteToChat: UIButton!
    @IBOutlet weak var imageProfile: UIImageView!    
    @IBOutlet weak var btClose: UIButton!
    
    var user:URUser!
    let chatRoomManager = URChatRoomManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundView.layer.cornerRadius = 5
        self.btInviteToChat.layer.cornerRadius = 4
        
        chatRoomManager.delegate = self
        
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
        self.btInviteToChat.setTitle("label_chat".localized, forState: UIControlState.Normal)
        self.lbPoints.text = "label_view_points".localized
        self.lbStories.text = "main_stories".localized
    }
    
    func setupUserInfo() {
        self.lbNickName.text = user.nickname
        
        if let contributions = user.contributions {
            self.lbContributions.text! = String(format: "stories_list_item_contributions".localized, arguments: [Int(contributions)])
        }else {
            self.lbContributions.text! = "no_contributions".localized
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
    
    //MARK: URChatRoomManagerDelegate
    
    func openChatRoom(chatRoom: URChatRoom, members: [URUser], title: String) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        URNavigationManager.navigation.pushViewController(URMessagesViewController(chatRoom: chatRoom, chatMembers: members, title: title), animated: true)
    }
    
    
    //MARK: Button Events
    
    @IBAction func btInviteToChatTapped(sender: AnyObject) {
        self.close()
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        chatRoomManager.createIndividualChatRoomIfPossible(user,isIndividualChatRoom: true)
    }
    
    @IBAction func btCloseTapped(sender: AnyObject) {
        self.close()
    }
    
}

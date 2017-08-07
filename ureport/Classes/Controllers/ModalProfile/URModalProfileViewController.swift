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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Modal Profile")
        
        if let builder = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable: Any] {
            tracker?.send(builder)
        }
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
        self.btInviteToChat.setTitle("label_chat".localized, for: UIControlState())
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
        self.roundedView.layer.borderColor = UIColor.white.cgColor
        
        if let picture = user.picture {
            self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(1)
            self.imageProfile.sd_setImage(with: URL(string: picture))
        }else{
            self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            self.imageProfile.contentMode = UIViewContentMode.center
            self.imageProfile.image = UIImage(named: "ic_person")
        }
        
        if self.user.key! == URUser.activeUser()!.key {
            self.btInviteToChat.isHidden = true
        }else{
            self.btInviteToChat.isHidden = false
        }
        
    }
    
    func close() {
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0)
            }, completion: { (finished) -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "modalProfileDidClosed"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }) 
        
    }
    
    //MARK: URChatRoomManagerDelegate
    
    func openChatRoom(_ chatRoom: URChatRoom, members: [URUser], title: String) {
        MBProgressHUD.hide(for: self.view, animated: true)
        URNavigationManager.navigation.pushViewController(URMessagesViewController(chatRoom: chatRoom, chatMembers: members, title: title), animated: true)
    }
    
    
    //MARK: Button Events
    
    @IBAction func btInviteToChatTapped(_ sender: AnyObject) {
        self.close()
        
        URUserManager.getByKey(user!.key, completion: { (friend:URUser?, exists:Bool) -> Void in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            if exists == true && friend != nil {
                self.chatRoomManager.createIndividualChatRoomIfPossible(friend!,isIndividualChatRoom: true)
            }
        })
        
    }
    
    @IBAction func btCloseTapped(_ sender: AnyObject) {
        self.close()
    }
    
}

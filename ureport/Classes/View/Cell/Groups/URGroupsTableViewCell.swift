//
//  URGroupsTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URGroupsTableViewCellDelegate {
    func btJoinDidTap(cell:URGroupsTableViewCell, groupChatRoom:URGroupChatRoom, members:[URUser], title:String)
}

class URGroupsTableViewCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var btJoin: UIButton!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var imageViewGroup: UIImageView!
    
    var groupChatRoom:URGroupChatRoom!
    
    var delegate:URGroupsTableViewCellDelegate!?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btJoin.layer.cornerRadius = 3
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    //MARK: Class Methods
    
    func setupCellWithData(groupChatRoom:URGroupChatRoom) {
        
        self.groupChatRoom = groupChatRoom
        self.lbTitle.text = groupChatRoom.title
        self.lbDescription.text = groupChatRoom.subject
        
        if groupChatRoom.userIsMember != nil && groupChatRoom.userIsMember == true{
            self.btJoin.setTitle("open".localized, forState: UIControlState.Normal)
        }else {
            self.btJoin.setTitle("chat_groups_join".localized, forState: UIControlState.Normal)
        }
        
        if let picture = groupChatRoom.picture {
            self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            self.imageViewGroup.contentMode = UIViewContentMode.ScaleAspectFill
            self.imageViewGroup.sd_setImageWithURL(NSURL(string: picture.url))
        }else{
            self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            self.imageViewGroup.image = UIImage(named: "default_group")
        }
        
    }
    
    //MARK: Button Events
    
    @IBAction func btJoinTapped(sender: AnyObject) {
        let user = URUser.activeUser()!
        
        ProgressHUD.show(nil)
        URChatMemberManager.getChatMembersByChatRoomWithCompletion(self.groupChatRoom.key, completionWithUsers: { (users:[URUser]) -> Void in
            ProgressHUD.dismiss()
            
            if self.groupChatRoom.userIsMember != nil && self.groupChatRoom.userIsMember == true {
                if let delegate = self.delegate {
                    delegate.btJoinDidTap(self, groupChatRoom: self.groupChatRoom, members: users, title: self.lbTitle.text! )
                }
            }else {
                let chatMember = URChatMember(key: self.groupChatRoom.key)
                
                URChatMemberManager.save(chatMember, user: user, completion: { (success:Bool) -> Void in
                    if success == true {
                        URGCMManager.registerUserInTopic(user, chatRoom: self.groupChatRoom)
                        URUserManager.updateChatroom(user, chatRoom: self.groupChatRoom)
                        
                        if let delegate = self.delegate {
                            delegate.btJoinDidTap(self, groupChatRoom: self.groupChatRoom, members: users, title: self.lbTitle.text!)
                        }
                        
                    }
                })
            }
            
        })
        
    }
    
}

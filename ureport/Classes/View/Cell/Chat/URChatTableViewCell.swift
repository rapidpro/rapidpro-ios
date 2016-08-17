//
//  URMyChatsTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

@objc protocol URChatTableViewCellDelegate {
    optional func userSelected(user:URUser)
}

class URChatTableViewCell: UITableViewCell {

    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDateHour: UILabel!
    @IBOutlet weak var lbUnreadMessages: UILabel!
    @IBOutlet weak var lbLastMessage: UILabel!
    @IBOutlet weak var viewLastMessage: UIView!
    @IBOutlet weak var viewCheckGroup: UIView!
    @IBOutlet weak var viewUnreadMessages: ISRoundedView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var btCheck: UIButton!
    
    var delegate:URChatTableViewCellDelegate?
    
    var chatRoom:URChatRoom?
    var user:URUser?
    var type: URChatCellType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if !URConstant.isIpad {
            super.selectionStyle = UITableViewCellSelectionStyle.None
        }else{            
            self.setSelectedBackgroundView()
        }
    }
    
    //MARK: Class Methods
    
    func setSelectedBackgroundView() {
        let view = UIView(frame: self.frame)
        view.backgroundColor = UIColor(rgba: "#DAF8FE")
        self.selectedBackgroundView = view
    }
    
    func setBtCheckSelected(selected:Bool) {
        if selected == true {
            btCheck.selected = true
            btCheck.setBackgroundImage(UIImage(named: "radio_button_active"), forState: UIControlState.Selected)
        }else {
            btCheck.selected = false
            btCheck.setBackgroundImage(UIImage(named: "radio_button_Inactive"), forState: UIControlState.Normal)
        }
    }
    
    func setupCellWithUser(user:URUser?,createGroupOption:Bool,indexPath:NSIndexPath, checkGroupOption:Bool) {
        
        self.user = user
        self.lbName.text = user!.nickname
        self.type = URChatCellType.CreateIndividualChat
        
        if user!.picture != nil && !(user!.picture.isEmpty) {
            self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            self.img.contentMode = UIViewContentMode.ScaleAspectFit
            self.img.sd_setImageWithURL(NSURL(string: user!.picture))
        }else{
            self.roundedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            self.img.contentMode = UIViewContentMode.Center
            self.img.image = UIImage(named: "ic_person")
        }
        
        if !checkGroupOption{
            self.viewLastMessage.hidden = true
        }else {
            self.viewLastMessage.hidden = true
            self.viewCheckGroup.hidden = false
        }
        
    }
    
    func setupCellWithChatRoom(chatRoom:URChatRoom) {                
        self.chatRoom = chatRoom
        
        if chatRoom is URGroupChatRoom {
            let groupChatRoom = (chatRoom as! URGroupChatRoom)
            
            self.lbName.text = groupChatRoom.title
            self.type = URChatCellType.Group
            self.lbLastMessage.text = groupChatRoom.lastMessage?.message
            self.lbDateHour.text = getTimeAgoFromDate(groupChatRoom)
            
            if groupChatRoom.totalUnreadMessages != nil && groupChatRoom.totalUnreadMessages > 0 {
                self.lbUnreadMessages.text = "\(groupChatRoom.totalUnreadMessages)"
                self.viewUnreadMessages.hidden = false
            }else {
                self.viewUnreadMessages.hidden = true
            }
            
            if let picture = groupChatRoom.picture {
                self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
                self.img.contentMode = UIViewContentMode.ScaleAspectFill
                if picture.url != nil && !picture.url.isEmpty{
                    self.img.sd_setImageWithURL(NSURL(string: picture.url))
                }else{
                    self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
                    self.img.image = UIImage(named: "default_group")
                }
            }
            
        }else if chatRoom is URIndividualChatRoom {
            
            let individualChatRoom = (chatRoom as! URIndividualChatRoom)
            self.chatRoom = individualChatRoom
            
            self.lbName.text = individualChatRoom.friend.nickname
            self.type = URChatCellType.Individual
            self.lbLastMessage.text = individualChatRoom.lastMessage?.message
            self.lbDateHour.text = getTimeAgoFromDate(individualChatRoom)
            self.lbUnreadMessages.text = "\(individualChatRoom.totalUnreadMessages)"
            
            if individualChatRoom.totalUnreadMessages != nil && individualChatRoom.totalUnreadMessages > 0 {
                self.lbUnreadMessages.text = "\(individualChatRoom.totalUnreadMessages)"
                self.viewUnreadMessages.hidden = false
            }else {
                self.viewUnreadMessages.hidden = true
            }
            
            if individualChatRoom.friend.picture != nil && !(individualChatRoom.friend.picture.isEmpty) {
                self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
                self.img.contentMode = UIViewContentMode.ScaleAspectFit
                self.img.sd_setImageWithURL(NSURL(string: individualChatRoom.friend.picture))
            }else{
                self.roundedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                self.img.contentMode = UIViewContentMode.Center
                self.img.image = UIImage(named: "ic_person")
            }
            
        }
        
        self.viewLastMessage.hidden = false
        
    }
    
    func setupUIWithChatRoom(chatRoom:URChatRoom){
        
    }
    
    func getTimeAgoFromDate(chatRoom:URChatRoom) -> String{
        if let lastMessage = chatRoom.lastMessage {
            let date:NSDate = NSDate(timeIntervalSince1970: NSNumber(double: lastMessage.date!.doubleValue/1000) as NSTimeInterval)
            return "\(NSDate().offsetFrom(date)) ago"
        }else {
            return ""
        }
    }
    
    //MARK: Button Events
    
    @IBAction func btCheckTapped(sender: AnyObject) {
        
        if btCheck.selected {
            setBtCheckSelected(false)
        }else{
            setBtCheckSelected(true)
        }
        
        if let delegate = self.delegate {
            delegate.userSelected!(self.user!)
        }
                
    }
    
}

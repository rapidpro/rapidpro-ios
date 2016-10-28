//
//  URMyChatsTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

@objc protocol URChatTableViewCellDelegate {
    @objc optional func userSelected(_ user:URUser)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if !URConstant.isIpad {
            super.selectionStyle = UITableViewCellSelectionStyle.none
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
    
    func setBtCheckSelected(_ selected:Bool) {
        if selected == true {
            btCheck.isSelected = true
            btCheck.setBackgroundImage(UIImage(named: "radio_button_active"), for: UIControlState.selected)
        }else {
            btCheck.isSelected = false
            btCheck.setBackgroundImage(UIImage(named: "radio_button_Inactive"), for: UIControlState())
        }
    }
    
    func setupCellWithUser(_ user:URUser?,createGroupOption:Bool,indexPath:IndexPath, checkGroupOption:Bool) {
        
        self.user = user
        self.lbName.text = user!.nickname
        self.type = URChatCellType.createIndividualChat
        
        if user!.picture != nil && !(user!.picture!.isEmpty) {
            self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(1)
            self.img.contentMode = UIViewContentMode.scaleAspectFill
            self.img.sd_setImage(with: URL(string: user!.picture!))
        }else{
            self.roundedView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            self.img.contentMode = UIViewContentMode.center
            self.img.image = UIImage(named: "ic_person")
        }
        
        if !checkGroupOption{
            self.viewLastMessage.isHidden = true
        }else {
            self.viewLastMessage.isHidden = true
            self.viewCheckGroup.isHidden = false
        }
        
    }
    
    func setupCellWithChatRoom(_ chatRoom:URChatRoom) {                
        self.chatRoom = chatRoom
        
        if chatRoom is URGroupChatRoom {
            let groupChatRoom = (chatRoom as! URGroupChatRoom)
            
            self.lbName.text = groupChatRoom.title
            self.type = URChatCellType.group
            self.lbLastMessage.text = groupChatRoom.lastMessage?.message
            self.lbDateHour.text = getTimeAgoFromDate(groupChatRoom)
            
            if groupChatRoom.totalUnreadMessages != nil && groupChatRoom.totalUnreadMessages > 0 {
                self.lbUnreadMessages.text = "\(groupChatRoom.totalUnreadMessages)"
                self.viewUnreadMessages.isHidden = false
            }else {
                self.viewUnreadMessages.isHidden = true
            }
            
            if let picture = groupChatRoom.picture {
                self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(1)
                self.img.contentMode = UIViewContentMode.scaleAspectFill
                if picture.url != nil && !picture.url.isEmpty{
                    self.img.sd_setImage(with: URL(string: picture.url))
                }else{
                    self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                    self.img.contentMode = UIViewContentMode.center
                    self.img.image = UIImage(named: "default_group")
                }
            }
            
        }else if chatRoom is URIndividualChatRoom {
            
            let individualChatRoom = (chatRoom as! URIndividualChatRoom)
            self.chatRoom = individualChatRoom
            
            self.lbName.text = individualChatRoom.friend.nickname
            self.type = URChatCellType.individual
            self.lbLastMessage.text = individualChatRoom.lastMessage?.message
            self.lbDateHour.text = getTimeAgoFromDate(individualChatRoom)
            self.lbUnreadMessages.text = "\(individualChatRoom.totalUnreadMessages)"
            
            if individualChatRoom.totalUnreadMessages != nil && individualChatRoom.totalUnreadMessages > 0 {
                self.lbUnreadMessages.text = "\(individualChatRoom.totalUnreadMessages)"
                self.viewUnreadMessages.isHidden = false
            }else {
                self.viewUnreadMessages.isHidden = true
            }
            
            if individualChatRoom.friend.picture != nil && !((individualChatRoom.friend.picture?.isEmpty)!) {
                self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(1)
                self.img.contentMode = UIViewContentMode.scaleAspectFit
                self.img.sd_setImage(with: URL(string: individualChatRoom.friend.picture!))
            }else{
                self.roundedView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
                self.img.contentMode = UIViewContentMode.center
                self.img.image = UIImage(named: "ic_person")
            }
            
        }
        
        self.viewLastMessage.isHidden = false
        
    }
    
    func setupUIWithChatRoom(_ chatRoom:URChatRoom){
        
    }
    
    func getTimeAgoFromDate(_ chatRoom:URChatRoom) -> String{
        if let lastMessage = chatRoom.lastMessage {
            let date:Date = Date(timeIntervalSince1970: NSNumber(value: lastMessage.date!.doubleValue/1000 as Double) as TimeInterval)
            return "\(Date().offsetFrom(date)) ago"
        }else {
            return ""
        }
    }
    
    //MARK: Button Events
    
    @IBAction func btCheckTapped(_ sender: AnyObject) {
        
        if btCheck.isSelected {
            setBtCheckSelected(false)
        }else{
            setBtCheckSelected(true)
        }
        
        if let delegate = self.delegate {
            delegate.userSelected!(self.user!)
        }
                
    }
    
}

//
//  URMessagesViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 26/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Foundation

class URMessagesViewController: JSQMessagesViewController, URChatMessageManagerDelegate {
    
    var chatRoom:URChatRoom!
    let chatMessage:URChatMessageManager = URChatMessageManager()
    var chatMembers:[URUser] = []
    
    var messages = [URChatMessage]()
    var avatars = Dictionary<String, UIImage>()

    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor(rgba: "#E8F9FF"))
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor(rgba: "#e5e5e5"))
    var senderImageUrl: String!
    
    var batchMessages = true
    var navigationTitle:String!

    init(chatRoom:URChatRoom!,chatMembers:[URUser],title:String){
        self.chatMembers = chatMembers
        self.chatRoom = chatRoom
        self.navigationTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = navigationTitle
        
        if self.chatRoom is URGroupChatRoom {
            self.navigationItem.rightBarButtonItems = self.addRightBarButtons()
        }
        
        inputToolbar!.contentView!.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        sender = (sender != nil) ? URUser.activeUser()?.nickname : "Anonymous"
        
        if let urlString = URUser.activeUser()!.picture {
            setupAvatarImage(sender, imageUrl: urlString as String, incoming: false)
            senderImageUrl = urlString as String
        } else {
            setupAvatarColor(sender, incoming: false)
            senderImageUrl = ""
        }
        
        chatMessage.delegate = self
        chatMessage.getMessages(self.chatRoom)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithType(.Blue)
        self.navigationController!.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        URChatMessageManager.getTotalMessages(chatRoom, completion: { (totalMessages:Int) -> Void in
            
            let messageRead = URMessageRead()
            messageRead.totalMessages = totalMessages
            messageRead.roomKey = self.chatRoom.key
            
            URMessageRead.saveMessageReadLocaly(messageRead)
        })
    }
    
    //MARK: Class Methods
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.characters.count
        let initials : String? = name.substringToIndex(sender.startIndex.advancedBy(min(3, nameLength)))
        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    func addRightBarButtons() -> [UIBarButtonItem]{
        
        self.navigationItem.rightBarButtonItem = nil
        
        let btnInfo: UIButton = UIButton(type: UIButtonType.Custom)
        
        let groupChatRoom = self.chatRoom as! URGroupChatRoom
        let container = UIView(frame: CGRectMake(0, 0, 36, 36))
        
        if groupChatRoom.picture != nil && groupChatRoom.picture.url != nil {
            btnInfo.frame = CGRectMake(0, 0, 36, 36)
            btnInfo.setBackgroundImageWithURL(NSURL(string: groupChatRoom.picture.url), forState: UIControlState.Normal)
            container.layer.cornerRadius = 18
        }else {
            btnInfo.frame = CGRectMake(0, 0, 32, 24)
            btnInfo.setBackgroundImage(UIImage(named: "ic_group"), forState: UIControlState.Normal)
            container.layer.cornerRadius = 0
        }
        
        btnInfo.addTarget(self, action: "openGroupDetail", forControlEvents: UIControlEvents.TouchUpInside)
        
        container.clipsToBounds = true
        container.addSubview(btnInfo)
        
        let infoItem = UIBarButtonItem(customView: container)
        
        return [infoItem]
    }
    
    func openGroupDetail() {
        URNavigationManager.navigation.pushViewController(URGroupDetailsViewController(groupChatRoom: self.chatRoom as! URGroupChatRoom,members:chatMembers), animated: true)
    }
    
    func sendMessage(text: String!) {
        
        let newMessage = URChatMessage()
        newMessage.user = URUser.activeUser()
        newMessage.message = text
        
        newMessage.date = NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000))
        
        URChatMessageManager.sendChatMessage(newMessage, chatRoom: chatRoom)
    }
    
    
    // ACTIONS
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text)
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("Camera pressed!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        
        if message.user.key == URUser.activeUser()?.key {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]

        if let avatar = avatars[message.sender()] {
            return UIImageView(image: avatar)
        } else {

            for user in chatMembers {
                if user.key == message.user.key {
                    if let pic = user.picture {
                        setupAvatarImage(message.sender(), imageUrl: pic, incoming: true)
                        return UIImageView(image:avatars[message.sender()])
                    }
                }
            }
            
            setupAvatarImage(message.sender(), imageUrl: "ic_person", incoming: true)
            return UIImageView(image:avatars[message.sender()])
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.user.key == URUser.activeUser()?.key {
            cell.textView!.textColor = UIColor.blackColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        let textColor = cell.textView!.textColor
        
        let attributes = [NSForegroundColorAttributeName:textColor!,NSUnderlineStyleAttributeName:1]
        cell.textView!.linkTextAttributes = attributes
        
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.user.key == URUser.activeUser()?.key {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.user.key == message.user.key {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.user.nickname)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.user.key == URUser.activeUser()?.key {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.user.key == message.user.key  {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    //MARK: URChatMessageDelegate
    
    func newMessageReceived(chatMessage: URChatMessage) {
        self.messages.append(chatMessage)
        self.finishReceivingMessage()
        
    }
    
}
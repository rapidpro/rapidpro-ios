//
//  URMessagesViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 26/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Foundation
import JSQMessagesViewController
import SDWebImage
import NYTPhotoViewer

protocol URMessagesViewControllerDelegate {
    func mediaButtonDidTap()
}

class URMessagesViewController: JSQMessagesViewController, URChatMessageManagerDelegate,JSQMessagesComposerTextViewPasteDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, URMediaSourceViewControllerDelegate, URAudioRecorderViewControllerDelegate {
    
    var chatRoom:URChatRoom?
    let chatMessage:URChatMessageManager = URChatMessageManager()
    var chatMembers:[URUser] = []
    
    var jsqMessages = [JSQMessage]()
    var users = Dictionary<String, String>()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()

    var senderImageUrl: String!
    var delegate: URMessagesViewControllerDelegate!
    var batchMessages = true
    var navigationTitle:String?

    var outgoingBubbleImageData:JSQMessagesBubbleImage!
    var incomingBubbleImageData:JSQMessagesBubbleImage!
    
    var userBlocked:Bool!
    
    var chatMessageList:[URChatMessage] = []
    let mediaSourceViewController = URMediaSourceViewController()
    
    var sendButton:UIButton!
    var keyboardIsVisible:Bool!
    
    init(chatRoom:URChatRoom?,chatMembers:[URUser],title:String?){
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
        sendButton = self.inputToolbar.contentView.rightBarButtonItem        
        
        setupJSQMessageLayout()
        loadMessagesController()
    }
    
    func loadMessagesController() {
        self.navigationItem.title = navigationTitle
        
        setupRightButtons()
        keyboardDidHide()
        setupAvatarImages()
        
        if self.chatRoom != nil && self.chatRoom!.key != nil && self.chatRoom!.key.characters.count > 0{
            self.jsqMessages = []
            self.collectionView.reloadData()
            chatMessage.delegate = self
            chatMessage.getMessages(self.chatRoom!)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide), name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioDidStartPlaying), name:"didStartPlaying", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout.springinessEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        URNavigationManager.setupNavigationBarWithType(.Blue)
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Chat Messages")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        updateReadMessages()
    }

    
    //MARK: MediaSourceViewControllerDelegate
    
    func newMediaAdded(mediaSourceViewController: URMediaSourceViewController, media: URMedia) {
        ProgressHUD.show(nil)
        URMediaUpload.uploadMedias([media]) { (medias) -> Void in
            self.sendMediaMessage(medias[0])
        }
    }
    
    //MARK: ChatMessageDelegate
    
    func newMessageReceived(chatMessage: URChatMessage) {
        setupChatMessage(chatMessage)
    }
    
    //MARK URAudioRecorderViewControllerDelegate
    
    func newAudioRecorded(audioRecorderViewController: URAudioRecorderViewController, media: URMedia) {
        ProgressHUD.show(nil)
        URMediaUpload.uploadMedias([media]) { (medias) -> Void in
            self.sendMediaMessage(medias[0])
        }
    }
    
    //MARK: Class Methods
    
    func updateReadMessages() {
        if chatRoom != nil {
            URChatMessageManager.getTotalMessages(chatRoom!, completion: { (totalMessages:Int) -> Void in
                
                let messageRead = URMessageRead()
                messageRead.totalMessages = totalMessages
                messageRead.roomKey = self.chatRoom!.key
                
                URMessageRead.saveMessageReadLocaly(messageRead)
            })
        }
    }
    
    func audioDidStartPlaying(notification:NSNotification) {
        for jsqMessage in jsqMessages {
            if jsqMessage.isMediaMessage {
                if jsqMessage.media is URChatAudioItem {
                    if let audioMediaView = jsqMessage.media.mediaView() as? URMediaAudioView {
                        if audioMediaView.audioView != notification.object as! URAudioView {
                            if audioMediaView.audioView.player != nil && audioMediaView.audioView.player.playing {
                                audioMediaView.audioView.play()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func keyboardDidShow() {
        keyboardIsVisible = true
        self.inputToolbar.contentView.rightBarButtonItem = sendButton
    }
    
    func keyboardDidHide() {
        keyboardIsVisible = false
        let micButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        micButton.setImage(UIImage(named: "icon_mic_blue"), forState: UIControlState.Normal)
        micButton.addTarget(self, action: #selector(openAudioRecorderController), forControlEvents: UIControlEvents.TouchUpInside)
        self.inputToolbar.contentView.rightBarButtonItem = nil
        self.inputToolbar.contentView.rightBarButtonItem = micButton
        self.inputToolbar.contentView.rightBarButtonItem.enabled = true
    }
    
    func openAudioRecorderController() {
        
        let audioRecorderViewController = URAudioRecorderViewController(audioURL: nil)
        audioRecorderViewController.delegate = self
        
        audioRecorderViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        URNavigationManager.navigation.presentViewController(audioRecorderViewController, animated: true) { () -> Void in
            UIView.animateWithDuration(0.3) { () -> Void in
                audioRecorderViewController.view.backgroundColor  = UIColor.blackColor().colorWithAlphaComponent(0.5)
            }
        }
    }
    
    func setupChatMessage(chatMessage:URChatMessage) {
        
        let date =  NSDate(timeIntervalSince1970: NSNumber(double: chatMessage.date!.doubleValue/1000) as NSTimeInterval)
        let maskAsOutgoing = URUser.activeUser()!.key == chatMessage.user.key
        chatMessageList.append(chatMessage)
        
        if let media = chatMessage.media {
            
            if media.type != nil {
                
                switch media.type {
                case URConstant.Media.PICTURE:

                    let chatImageItem = URChatImageItem(media: media, viewController: self, maskAsOutgoing: maskAsOutgoing)
                    self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media: chatImageItem))
                    self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.jsqMessages.count-1, inSection: 0)])
                    self.scrollToBottomAnimated(true)
                    
                    break
                case URConstant.Media.AUDIO:
                    let chatAudioItem = URChatAudioItem(media:media,maskAsOutgoing: maskAsOutgoing)
                    self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media: chatAudioItem))
                    self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.jsqMessages.count-1, inSection: 0)])
                    self.scrollToBottomAnimated(true)
                    break
                case URConstant.Media.FILE:
//                    
                    self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media:URChatFileItem(media: media, maskAsOutgoing: maskAsOutgoing)))
                    
                    self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.jsqMessages.count-1, inSection: 0)])
                    self.scrollToBottomAnimated(true)
                    
                    break
                case URConstant.Media.VIDEO:
                    
                    let mediaItem = URChatVideoItem(media: media, maskAsOutgoing: maskAsOutgoing)
                                        
                    self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media:mediaItem))
                    
                    self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.jsqMessages.count-1, inSection: 0)])
                    self.scrollToBottomAnimated(true)
                    break
                case URConstant.Media.VIDEOPHONE:
                    
                    if media.thumbnail != nil {
                        let chatVideoItem = URChatVideoPhoneItem(media: media, maskAsOutgoing: maskAsOutgoing, viewController: self)
                        self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media: chatVideoItem))
                        
                        self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.jsqMessages.count-1, inSection: 0)])
                        self.scrollToBottomAnimated(true)
                    }
                    break
                default:
                    break
                }
            }else if chatMessage.message != nil {
                
                self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, text: chatMessage.message))
                self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.jsqMessages.count-1, inSection: 0)])
                self.scrollToBottomAnimated(true)
            }
            
        }else{
            
            self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, text: chatMessage.message))
            self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.jsqMessages.count-1, inSection: 0)])
            self.scrollToBottomAnimated(true)
        }
        
    }
    
    func setupJSQMessageLayout() {
        self.inputToolbar!.contentView!.textView!.pasteDelegate = self;
        
        self.senderDisplayName = (senderDisplayName != nil) ? URUser.activeUser()?.nickname : "Anonymous"
        self.senderId = URUser.activeUser()!.key
        
        if NSUserDefaults.incomingAvatarSetting() {
            self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        }
        if !NSUserDefaults.outgoingAvatarSetting() {
            self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        }
        
        self.showLoadEarlierMessagesHeader = false
        
        let bubbleFactory: JSQMessagesBubbleImageFactory = JSQMessagesBubbleImageFactory()
        self.outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
    
    func setupRightButtons() {
        if chatRoom == nil {
            return
        }else if self.chatRoom!.type == URChatRoomType.Group {
            self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForGroupChatRoom()
        }else {
            let individualChatRoom = self.chatRoom as? URIndividualChatRoom
            
            userBlocked = false
            
            self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForIndividualChatRoom()
            
            if let blocked = individualChatRoom?.blocked {
                
                self.collectionView!.userInteractionEnabled = false
                self.inputToolbar!.userInteractionEnabled = false
                
                if blocked == URUser.activeUser()!.key {
                    userBlocked = true
                    
                    self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForIndividualChatRoom()
                    
                    let alertController = UIAlertController(title: nil, message: "message_confirm_unblock_user".localized, preferredStyle: .Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: "label_unblock_chat_room".localized, style: .Default, handler: { (alertAction) -> Void in
                        URChatRoomManager.unblockUser(self.chatRoom!.key)
                        self.userBlocked = false
                        self.collectionView!.userInteractionEnabled = true
                        self.inputToolbar!.userInteractionEnabled = true
                        
                        self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForIndividualChatRoom()
                        
                    }))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }else {
                    
                    let alertController = UIAlertController(title: nil, message: String(format: "message_individual_chat_blocked".localized, arguments: [self.navigationTitle!]), preferredStyle: .Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { (alertAction) -> Void in
                        self.navigationController!.popViewControllerAnimated(true)
                    }))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
                
            }else{
                userBlocked = false
            }
        }
    }
    
    func setupAvatarImages() {
        for user in chatMembers {
            
            if let picture = user.picture {
                
                SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: picture), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                    
                    }, completed: { (image, error, cache, finish, url) -> Void in
                        if image != nil {
                            let userImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 30)
                            self.avatars[user.key] = userImage
                            self.users[user.key] = user.nickname
                        }
                })
                
            }
            
        }
    }
    
    func addRightBarButtonsForGroupChatRoom() -> [UIBarButtonItem]{
        
        self.navigationItem.rightBarButtonItem = nil
        
        let btnInfo: UIButton = UIButton(type: UIButtonType.Custom)
        
        let groupChatRoom = self.chatRoom as! URGroupChatRoom
        let container = UIView(frame: CGRectMake(0, 0, 36, 36))
        
        if groupChatRoom.picture != nil && groupChatRoom.picture.url != nil {
            btnInfo.frame = CGRectMake(0, 7, 21, 21)
            btnInfo.sd_setBackgroundImageWithURL(NSURL(string: groupChatRoom.picture.url), forState: UIControlState.Normal)
            container.layer.cornerRadius = 18
        }else {
            btnInfo.frame = CGRectMake(0, 7, 29, 18)
            btnInfo.setBackgroundImage(UIImage(named: "ic_group"), forState: UIControlState.Normal)
            container.layer.cornerRadius = 0
        }
        
        btnInfo.addTarget(self, action: #selector(openGroupDetail), forControlEvents: UIControlEvents.TouchUpInside)
        
        container.clipsToBounds = true
        container.addSubview(btnInfo)
        
        let infoItem = UIBarButtonItem(customView: container)
        
        return [infoItem]
    }
    
    func addRightBarButtonsForIndividualChatRoom() -> [UIBarButtonItem]{
        
        self.navigationItem.rightBarButtonItem = nil
        
        let btnInfo: UIButton = UIButton(type: UIButtonType.Custom)
        
        let container = UIView(frame: CGRectMake(0, 0, 36, 36))
        
        btnInfo.frame = CGRectMake(0, 7, 21, 19)
        btnInfo.setBackgroundImage(UIImage(named: userBlocked == true ?  "icon_unblock" : "icon_block"), forState: UIControlState.Normal)
        container.layer.cornerRadius = 0
        
        btnInfo.addTarget(self, action: #selector(blockUserIfNeccessary), forControlEvents: UIControlEvents.TouchUpInside)
        
        container.clipsToBounds = true
        container.addSubview(btnInfo)
        
        let infoItem = UIBarButtonItem(customView: container)
        
        return [infoItem]
    }
    
    func blockUserIfNeccessary() {
        if userBlocked == true {
            unblockUser()
        }else{
            blockUser()
        }
    }
    
    func blockUser() {
        let alertController = UIAlertController(title: nil, message: "message_confirm_block_user".localized, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "block_chat_room".localized, style: .Default, handler: { (alertAction) -> Void in
            URChatRoomManager.blockUser(self.chatRoom!.key)
            self.collectionView!.userInteractionEnabled = false
            self.inputToolbar!.userInteractionEnabled = false
            self.userBlocked = true
            self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForIndividualChatRoom()
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: .Cancel, handler: nil))
        self.navigationController!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func unblockUser() {
        let alertController = UIAlertController(title: nil, message: "message_confirm_unblock_user".localized, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "label_unblock_chat_room".localized, style: .Default, handler: { (alertAction) -> Void in
            URChatRoomManager.unblockUser(self.chatRoom!.key)
            self.collectionView!.userInteractionEnabled = true
            self.inputToolbar!.userInteractionEnabled = true
            self.userBlocked = false
            self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForIndividualChatRoom()
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: .Cancel, handler: nil))
        self.navigationController!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func openGroupDetail() {
        URNavigationManager.navigation.pushViewController(URGroupDetailsViewController(groupChatRoom: self.chatRoom as! URGroupChatRoom,members:chatMembers), animated: true)
    }
    
    func sendTextMessage(text: String!) {
        
        let newMessage = URChatMessage()
        newMessage.user = URUser.activeUser()
        newMessage.message = text
        newMessage.date = NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000))
        
        URChatMessageManager.sendChatMessage(newMessage, chatRoom: chatRoom!)
        updateReadMessages()
        
        self.finishSendingMessage()        
    }
    
    func sendMediaMessage(media: URMedia!) {
        
        let newMessage = URChatMessage()
        newMessage.user = URUser.activeUser()
        newMessage.media = media
        newMessage.date = NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000))
        
        URChatMessageManager.sendChatMessage(newMessage, chatRoom: chatRoom!)
        updateReadMessages()
        
        dispatch_async(dispatch_get_main_queue()) {
            ProgressHUD.dismiss()
            if media.type != URConstant.Media.AUDIO {
                self.mediaSourceViewController.toggleView({ (finish) in })
            }
        }
    }
    
    //MARK: JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        if keyboardIsVisible == true {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.sendTextMessage(text)
            finishSendingMessageAnimated(true)
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton) {
        
        self.inputToolbar.contentView.textView.resignFirstResponder()
        
        if let delegate = self.delegate {
            delegate.mediaButtonDidTap()
        }else {
            self.view.addSubview(mediaSourceViewController.view)
            mediaSourceViewController.delegate = self
            mediaSourceViewController.toggleView { (finish) -> Void in}
        }
    }
    
    //MARK: JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        return self.jsqMessages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, didDeleteMessageAtIndexPath indexPath: NSIndexPath) {
        self.jsqMessages.removeAtIndex(indexPath.item)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource {
        let message = self.jsqMessages[indexPath.item]
        if (message.senderId == senderId) {
            return self.outgoingBubbleImageData
        }
        return self.incomingBubbleImageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = self.jsqMessages[indexPath.item]
        if (message.senderId == senderId) {
            if !NSUserDefaults.outgoingAvatarSetting() {
                return nil
            }
        }else {
            if !NSUserDefaults.incomingAvatarSetting() {
                return nil
            }
        }
        return self.avatars[message.senderId]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        if indexPath.item % 3 == 0 {
        let message: JSQMessage = self.jsqMessages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        let message = self.jsqMessages[indexPath.item]
        if (message.senderId == senderId) {
            return nil
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = self.jsqMessages[indexPath.item - 1]
            if (previousMessage.senderId == message.senderId) {
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        return nil
    }
    
    //MARK: UICollectionView DataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.jsqMessages.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let msg = self.jsqMessages[indexPath.item]
        if !msg.isMediaMessage {
            if (msg.senderId == senderId) {
                cell.textView!.textColor = UIColor.blackColor()
            }
            else {
                cell.textView!.textColor = UIColor.whiteColor()
            }
            cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView!.textColor!, NSUnderlineStyleAttributeName: [NSUnderlineStyle.StyleSingle.rawValue | NSUnderlineStyle.PatternSolid.rawValue]]
        }
        return cell
    }
    
    //MARK: Adjusting cell label heights
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let currentMessage = self.jsqMessages[indexPath.item]
        if (currentMessage.senderId == senderId) {
            return 0.0
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = self.jsqMessages[indexPath.item - 1]
            if (previousMessage.senderId == currentMessage.senderId) {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0.0
    }
    
    //MARK: Responding to collection view tap events
    
    override func collectionView(collectionView: JSQMessagesCollectionView, header headerView: JSQMessagesLoadEarlierHeaderView, didTapLoadEarlierMessagesButton sender: UIButton) {
        NSLog("Load earlier messages!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, didTapAvatarImageView avatarImageView: UIImageView, atIndexPath indexPath: NSIndexPath) {
        NSLog("Tapped avatar!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath) {
        let jsqMessage = self.jsqMessages[indexPath.item]
        
        if jsqMessage.media is URChatVideoItem {
            print("URChatVideoItem tapped")
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, didTapCellAtIndexPath indexPath: NSIndexPath, touchLocation: CGPoint) {
        NSLog("Tapped cell at %@!", NSStringFromCGPoint(touchLocation))
    }
    
    //MARK: JSQMessagesComposerTextViewPasteDelegate methods
    
    func composerTextView(textView: JSQMessagesComposerTextView, shouldPasteWithSender sender: AnyObject) -> Bool {
        if let _ = UIPasteboard.generalPasteboard().image {
//            let item: JSQPhotoMediaItem = JSQPhotoMediaItem(image: UIPasteboard.generalPasteboard().image)
//            let message: URChatMessage = URChatMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: item)
//            self.messages.append(message)
//            finishSendingMessage()
            return false
        }
        return true
    }
    
}
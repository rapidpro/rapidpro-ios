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
import youtube_ios_player_helper

protocol URMessagesViewControllerDelegate {
    func didDismissJSQDemoViewController(messagesViewController:URMessagesViewController)
}

class URMessagesViewController: JSQMessagesViewController, URChatMessageManagerDelegate,JSQMessagesComposerTextViewPasteDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, NYTPhotosViewControllerDelegate {
    
    var chatRoom:URChatRoom!
    let chatMessage:URChatMessageManager = URChatMessageManager()
    var chatMembers:[URUser] = []
    
    var jsqMessages = [JSQMessage]()
    var mediaList = [URMedia]()
    var users = Dictionary<String, String>()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()

    var senderImageUrl: String!
    var delegate: URMessagesViewControllerDelegate!
    var batchMessages = true
    var navigationTitle:String!

    var outgoingBubbleImageData:JSQMessagesBubbleImage!
    var incomingBubbleImageData:JSQMessagesBubbleImage!
    
    var mediaCount:Int!
    var userBlocked:Bool!
    
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
        
        self.mediaCount = 1
        self.navigationItem.title = navigationTitle
        
        setupRightButtons()
        setupJSQMessageLayout()
        
        setupAvatarImages()        
        
        UIMenuController.sharedMenuController().menuItems = [UIMenuItem(title: "Custom Action", action: "customAction:")]
        
        chatMessage.delegate = self
        chatMessage.getMessages(self.chatRoom)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout.springinessEnabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithType(.Blue)
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        
        if let _ = self.delegate {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "closePressed:")
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Chat Messages")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
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
    
    //MARK: Action
    
    func addPhotoMediaMessage() {
//        let photoItem: JSQPhotoMediaItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
//        var photoMessage: JSQMessage = JSQMessage.messageWithSenderId(kJSQDemoAvatarIdSquires, displayName: kJSQDemoAvatarDisplayNameSquires, media: photoItem)
//        messages.addObject(photoMessage)
    }
    
    func addLocationMediaMessageCompletion(completion: JSQLocationMediaItemCompletionBlock) {
//        let ferryBuildingInSF: CLLocation = CLLocation(latitude: 37.795313, longitude: -122.393757)
//        let locationItem: JSQLocationMediaItem = JSQLocationMediaItem()
//        locationItem.setLocation(ferryBuildingInSF, withCompletionHandler: completion)
//        var locationMessage: JSQMessage = JSQMessage.messageWithSenderId(kJSQDemoAvatarIdSquires, displayName: kJSQDemoAvatarDisplayNameSquires, media: locationItem)
//        messages.addObject(locationMessage)
    }
    
    func addVideoMediaMessage() {
//        var videoURL: NSURL = NSURL(string: "file://")
//        var videoItem: JSQVideoMediaItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
//        var videoMessage: JSQMessage = JSQMessage.messageWithSenderId(kJSQDemoAvatarIdSquires, displayName: kJSQDemoAvatarDisplayNameSquires, media: videoItem)
//        messages.addObject(videoMessage)
    }
    
    //MARK: ChatMessageDelegate
    
    func newMessageReceived(chatMessage: URChatMessage) {
        
        let date =  NSDate(timeIntervalSince1970: NSNumber(double: chatMessage.date!.doubleValue/1000) as NSTimeInterval)
    
        if chatMessage.media != nil && chatMessage.media!.url != nil {

            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:chatMessage.media!.url), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                
                }, completed: { (image, error, cacheType, finish, url) -> Void in
                    
                    let mediaItem = JSQPhotoMediaItem(image: image)
                    
                    self.mediaList.append(chatMessage.media!)
                    mediaItem.mediaView().tag = self.mediaCount
                    
                    self.mediaCount = self.mediaCount + 1
                    
                    if chatMessage.media!.type == URConstant.Media.PICTURE {
                        self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media: mediaItem))
                    }else{
                        
                        let frame = CGRect(x: 0, y: 0, width: mediaItem.mediaView().frame.size.width, height: mediaItem.mediaView().frame.size.height)
                        let playerView = YTPlayerView(frame: frame)
                        mediaItem.mediaView().addSubview(playerView)
                        playerView.loadWithVideoId(chatMessage.media!.id)
                        
                        self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media:                     mediaItem))
                    }

                    self.finishReceivingMessage()
                    
            })
            
        }else{
            self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, text: chatMessage.message))
            self.finishReceivingMessage()
        }
        
    }
    
    //MARK: Class Methods
    
    func setupJSQMessageLayout() {
        self.inputToolbar!.contentView!.textView!.pasteDelegate = self;
        automaticallyScrollsToMostRecentMessage = true
        
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
        if self.chatRoom is URGroupChatRoom {
            self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForGroupChatRoom()
        }else {
            if self.chatRoom is URIndividualChatRoom {
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
                            URChatRoomManager.unblockUser(self.chatRoom.key)
                            self.userBlocked = false
                            self.collectionView!.userInteractionEnabled = true
                            self.inputToolbar!.userInteractionEnabled = true
                            
                            self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForIndividualChatRoom()
                            
                        }))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    }else {
                        
                        let alertController = UIAlertController(title: nil, message: String(format: "message_individual_chat_blocked".localized, arguments: [self.navigationTitle]), preferredStyle: .Alert)
                        
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
    
    func closePressed(sender: UIBarButtonItem) {
        if let delegate = self.delegate {
            delegate.didDismissJSQDemoViewController(self)
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
        
        btnInfo.addTarget(self, action: "openGroupDetail", forControlEvents: UIControlEvents.TouchUpInside)
        
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
        
        btnInfo.addTarget(self, action: "blockUserIfNeccessary", forControlEvents: UIControlEvents.TouchUpInside)
        
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
            URChatRoomManager.blockUser(self.chatRoom.key)
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
            URChatRoomManager.unblockUser(self.chatRoom.key)
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
        
        URChatMessageManager.sendChatMessage(newMessage, chatRoom: chatRoom)
        self.finishSendingMessage()        
    }
    
    func sendMediaMessage(media: URMedia!) {
        
        let newMessage = URChatMessage()
        newMessage.user = URUser.activeUser()
        newMessage.media = media
        newMessage.date = NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000))
        
        URChatMessageManager.sendChatMessage(newMessage, chatRoom: chatRoom)
                
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            dispatch_async(dispatch_get_main_queue(), {
                ProgressHUD.dismiss()
                })
            })
    }
    
    //MARK: ImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ProgressHUD.show(nil)
            URAWSManager.uploadImage(pickedImage, uploadPath: .Chat, completion: { (media:URMedia?) -> Void in
                self.sendMediaMessage(media!)
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    //MARK: JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.sendTextMessage(text)
        finishSendingMessageAnimated(true)
    }
    
    override func didPressAccessoryButton(sender: UIButton) {
//        let sheet = UIActionSheet(title: "Media messages", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Send photo", "Send youtube video", "")
//        sheet.showFromToolbar(inputToolbar!)
        let alertController = UIAlertController(title: "", message: "title_media_source".localized, preferredStyle: .ActionSheet)

        alertController.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: UIAlertActionStyle.Cancel, handler:nil))
        
        alertController.addAction(UIAlertAction(title: "choose_take_picture".localized, style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
            imagePicker.showsCameraControls = true
            imagePicker.allowsEditing = true
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "choose_camera".localized, style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "hint_youtube_link".localized, style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
            
            let alertControllerTextField = UIAlertController(title: nil, message: "message_youtube_link".localized, preferredStyle: UIAlertControllerStyle.Alert)
            
            alertControllerTextField.addTextFieldWithConfigurationHandler(nil)
            
            alertControllerTextField.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: .Cancel, handler: nil))
            
            alertControllerTextField.addAction(UIAlertAction(title: "sign_up_confirm".localized, style: .Default, handler: { (alertAction) -> Void in
                
                let urlVideo = alertControllerTextField.textFields![0].text!
                
                if urlVideo.isEmpty {
                    UIAlertView(title: nil, message: "error_empty_link".localized, delegate: self, cancelButtonTitle: "OK").show()
                    return
                }
                
                let media = URMedia()
                let videoID = URYoutubeUtil.getYoutubeVideoID(urlVideo)
                media.id = videoID
                media.url = URConstant.Youtube.COVERIMAGE.stringByReplacingOccurrencesOfString("%@", withString: videoID!)
                media.type = URConstant.Media.VIDEO
                self.sendMediaMessage(media)
            }))
            
            self.presentViewController(alertControllerTextField, animated: true, completion: nil)
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
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
    
    //MARK: Custom menu items
    
//    func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool {
//        if action == "customAction:" {
//            return true
//        }
//        return super.collectionView(collectionView, canPerformAction: action, forItemAtIndexPath: indexPath, withSender: sender)
//    }
//    
//    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) {
//        if action == "customAction:" {
//            customAction(sender)
//            return
//        }
//        super.collectionView(collectionView, performAction: action, forItemAtIndexPath: indexPath, withSender: sender)
//    }
    
    func customAction(sender: AnyObject) {
//        NSLog("Custom action received! Sender: %@", sender)
        UIAlertView(title: "Custom Action", message: "Custom action received", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
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
    
    //MARK: PhotosViewControllerDelegate
    
    func photosViewControllerDidDismiss(photosViewController: NYTPhotosViewController!) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
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
        
        if jsqMessage.isMediaMessage == true {
            let index = (jsqMessage.media.mediaView().tag) - 1
            
            let media = self.mediaList[index] as URMedia
            
            if (media.type == URConstant.Media.PICTURE) {
                SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: media.url), options: SDWebImageOptions.CacheMemoryOnly, progress: { (size, expectedSize) -> Void in
                    
                    }, completed: { (image, error, cache, finish, url) -> Void in
                        
                        let photosViewController = NYTPhotosViewController(photos: [PhotoShow(image: image, attributedCaptionTitle: NSAttributedString(string: ""))])
                        photosViewController.delegate = self
                        
                        self.presentViewController(photosViewController, animated: true, completion: { () -> Void in
                            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
                        })
   
                })
            }else{
                (jsqMessage.media.mediaView().subviews[jsqMessage.media.mediaView().subviews.count-1] as! YTPlayerView).playVideo()
            }
        }
        
        NSLog("Tapped message bubble!")
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
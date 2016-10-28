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
import MBProgressHUD

protocol URMessagesViewControllerDelegate {
    func mediaButtonDidTap()
}

class URMessagesViewController: JSQMessagesViewController, URChatMessageManagerDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, URMediaSourceViewControllerDelegate, URAudioRecorderViewControllerDelegate {
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioDidStartPlaying), name:NSNotification.Name(rawValue: "didStartPlaying"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout.springinessEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        URNavigationManager.setupNavigationBarWithType(.blue)
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Chat Messages")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateReadMessages()
    }

    
    //MARK: MediaSourceViewControllerDelegate
    
    func newMediaAdded(_ mediaSourceViewController: URMediaSourceViewController, media: URMedia) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        URMediaUpload.uploadMedias([media]) { (medias) -> Void in
            self.sendMediaMessage(medias[0])
        }
    }
    
    //MARK: ChatMessageDelegate
    
    func newMessageReceived(_ chatMessage: URChatMessage) {
        setupChatMessage(chatMessage)
    }
    
    //MARK URAudioRecorderViewControllerDelegate
    
    func newAudioRecorded(_ audioRecorderViewController: URAudioRecorderViewController, media: URMedia) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        URMediaUpload.uploadMedias([media]) { (medias) -> Void in
            self.sendMediaMessage(medias[0])
        }
    }
    
    //MARK: Class Methods
    
    func updateReadMessages() {
        if chatRoom != nil {
            URChatMessageManager.getTotalMessages(chatRoom!, completion: { (totalMessages:Int) -> Void in
                
                let messageRead = URMessageRead()
                messageRead.totalMessages = totalMessages as NSNumber!
                messageRead.roomKey = self.chatRoom!.key
                
                URMessageRead.saveMessageReadLocaly(messageRead)
            })
        }
    }
    
    func audioDidStartPlaying(_ notification:Notification) {
        for jsqMessage in jsqMessages {
            if jsqMessage.isMediaMessage {
                if jsqMessage.media is URChatAudioItem {
                    if let audioMediaView = jsqMessage.media.mediaView() as? URMediaAudioView {
                        if audioMediaView.audioView != notification.object as! URAudioView {
                            if audioMediaView.audioView.player != nil && audioMediaView.audioView.player.isPlaying {
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
        micButton.setImage(UIImage(named: "icon_mic_blue"), for: UIControlState())
        micButton.addTarget(self, action: #selector(openAudioRecorderController), for: UIControlEvents.touchUpInside)
        self.inputToolbar.contentView.rightBarButtonItem = nil
        self.inputToolbar.contentView.rightBarButtonItem = micButton
        self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
    }
    
    func openAudioRecorderController() {
        
        let audioRecorderViewController = URAudioRecorderViewController(audioURL: nil)
        audioRecorderViewController.delegate = self
        
        audioRecorderViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        URNavigationManager.navigation.present(audioRecorderViewController, animated: true) { () -> Void in
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                audioRecorderViewController.view.backgroundColor  = UIColor.black.withAlphaComponent(0.5)
            }) 
        }
    }
    
    func setupChatMessage(_ chatMessage:URChatMessage) {
        
        let date =  Date(timeIntervalSince1970: NSNumber(value: chatMessage.date!.doubleValue/1000 as Double) as TimeInterval)
        let maskAsOutgoing = URUser.activeUser()!.key == chatMessage.user.key
        chatMessageList.append(chatMessage)
        
        if let media = chatMessage.media {
            
            if media.type != nil {
                
                switch media.type! {
                case URConstant.Media.PICTURE:

                    let chatImageItem = URChatImageItem(media: media, viewController: self, maskAsOutgoing: maskAsOutgoing)
                    self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media: chatImageItem))
                    self.collectionView.insertItems(at: [IndexPath(item: self.jsqMessages.count-1, section: 0)])
                    self.scrollToBottom(animated: true)
                    
                    break
                case URConstant.Media.AUDIO:
                    let chatAudioItem = URChatAudioItem(media:media,maskAsOutgoing: maskAsOutgoing)
                    self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media: chatAudioItem))
                    self.collectionView.insertItems(at: [IndexPath(item: self.jsqMessages.count-1, section: 0)])
                    self.scrollToBottom(animated: true)
                    break
                case URConstant.Media.FILE:
//                    
                    self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media:URChatFileItem(media: media, maskAsOutgoing: maskAsOutgoing)))
                    
                    self.collectionView.insertItems(at: [IndexPath(item: self.jsqMessages.count-1, section: 0)])
                    self.scrollToBottom(animated: true)
                    
                    break
                case URConstant.Media.VIDEO:
                    
                    let mediaItem = URChatVideoItem(media: media, maskAsOutgoing: maskAsOutgoing)
                                        
                    self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media:mediaItem))
                    
                    self.collectionView.insertItems(at: [IndexPath(item: self.jsqMessages.count-1, section: 0)])
                    self.scrollToBottom(animated: true)
                    break
                case URConstant.Media.VIDEOPHONE:
                    
                    if media.thumbnail != nil {
                        let chatVideoItem = URChatVideoPhoneItem(media: media, maskAsOutgoing: maskAsOutgoing, viewController: self)
                        self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, media: chatVideoItem))
                        
                        self.collectionView.insertItems(at: [IndexPath(item: self.jsqMessages.count-1, section: 0)])
                        self.scrollToBottom(animated: true)
                    }
                    break
                default:
                    break
                }
            }else if chatMessage.message != nil {
                
                self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, text: chatMessage.message))
                self.collectionView.insertItems(at: [IndexPath(item: self.jsqMessages.count-1, section: 0)])
                self.scrollToBottom(animated: true)
            }
            
        }else{
            
            self.jsqMessages.append(JSQMessage(senderId: chatMessage.user.key, senderDisplayName: chatMessage.user.nickname, date: date, text: chatMessage.message))
            self.collectionView.insertItems(at: [IndexPath(item: self.jsqMessages.count-1, section: 0)])
            self.scrollToBottom(animated: true)
        }
        
    }
    
    func setupJSQMessageLayout() {
        
        self.senderDisplayName = (senderDisplayName != nil) ? URUser.activeUser()?.nickname : "Anonymous"
        self.senderId = URUser.activeUser()!.key
        
        if UserDefaults.incomingAvatarSetting() {
            self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        }
        if !UserDefaults.outgoingAvatarSetting() {
            self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        }
        
        self.showLoadEarlierMessagesHeader = false
        
        let bubbleFactory: JSQMessagesBubbleImageFactory = JSQMessagesBubbleImageFactory()
        self.outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
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
                
                self.collectionView!.isUserInteractionEnabled = false
                self.inputToolbar!.isUserInteractionEnabled = false
                
                if blocked == URUser.activeUser()!.key {
                    userBlocked = true
                    
                    self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForIndividualChatRoom()
                    
                    let alertController = UIAlertController(title: nil, message: "message_confirm_unblock_user".localized, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: "label_unblock_chat_room".localized, style: .default, handler: { (alertAction) -> Void in
                        URChatRoomManager.unblockUser(self.chatRoom!.key)
                        self.userBlocked = false
                        self.collectionView!.isUserInteractionEnabled = true
                        self.inputToolbar!.isUserInteractionEnabled = true
                        
                        self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForIndividualChatRoom()
                        
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }else {
                    
                    let alertController = UIAlertController(title: nil, message: String(format: "message_individual_chat_blocked".localized, arguments: [self.navigationTitle!]), preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (alertAction) -> Void in
                        self.navigationController!.popViewController(animated: true)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
            }else{
                userBlocked = false
            }
        }
    }
    
    func setupAvatarImages() {
        for user in chatMembers {
            
            if let picture = user.picture {
                
                SDWebImageManager.shared().downloadImage(with: URL(string: picture), options: SDWebImageOptions.avoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                    
                    }, completed: { (image, error, cache, finish, url) -> Void in
                        if image != nil {
                            let userImage = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
                            self.avatars[user.key] = userImage
                            self.users[user.key] = user.nickname
                        }
                })
                
            }
            
        }
    }
    
    func addRightBarButtonsForGroupChatRoom() -> [UIBarButtonItem]{
        
        self.navigationItem.rightBarButtonItem = nil
        
        let btnInfo: UIButton = UIButton(type: UIButtonType.custom)
        
        let groupChatRoom = self.chatRoom as! URGroupChatRoom
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        
        if groupChatRoom.picture != nil && groupChatRoom.picture.url != nil {
            btnInfo.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
            btnInfo.sd_setBackgroundImage(with: URL(string: groupChatRoom.picture.url), for: UIControlState())
            container.layer.cornerRadius = 18
        }else {
            btnInfo.frame = CGRect(x: 0, y: 7, width: 29, height: 18)
            btnInfo.setBackgroundImage(UIImage(named: "ic_group"), for: UIControlState())
            container.layer.cornerRadius = 0
        }
        
        btnInfo.addTarget(self, action: #selector(openGroupDetail), for: UIControlEvents.touchUpInside)
        
        container.clipsToBounds = true
        container.addSubview(btnInfo)
        
        let infoItem = UIBarButtonItem(customView: container)
        
        return [infoItem]
    }
    
    func addRightBarButtonsForIndividualChatRoom() -> [UIBarButtonItem]{
        
        self.navigationItem.rightBarButtonItem = nil
        
        let btnInfo: UIButton = UIButton(type: UIButtonType.custom)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        
        btnInfo.frame = CGRect(x: 0, y: 7, width: 21, height: 19)
        btnInfo.setBackgroundImage(UIImage(named: userBlocked == true ?  "icon_unblock" : "icon_block"), for: UIControlState())
        container.layer.cornerRadius = 0
        
        btnInfo.addTarget(self, action: #selector(blockUserIfNeccessary), for: UIControlEvents.touchUpInside)
        
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
        let alertController = UIAlertController(title: nil, message: "message_confirm_block_user".localized, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "block_chat_room".localized, style: .default, handler: { (alertAction) -> Void in
            URChatRoomManager.blockUser(self.chatRoom!.key)
            self.collectionView!.isUserInteractionEnabled = false
            self.inputToolbar!.isUserInteractionEnabled = false
            self.userBlocked = true
            self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForIndividualChatRoom()
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: .cancel, handler: nil))
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func unblockUser() {
        let alertController = UIAlertController(title: nil, message: "message_confirm_unblock_user".localized, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "label_unblock_chat_room".localized, style: .default, handler: { (alertAction) -> Void in
            URChatRoomManager.unblockUser(self.chatRoom!.key)
            self.collectionView!.isUserInteractionEnabled = true
            self.inputToolbar!.isUserInteractionEnabled = true
            self.userBlocked = false
            self.navigationItem.rightBarButtonItems = self.addRightBarButtonsForIndividualChatRoom()
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: .cancel, handler: nil))
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func openGroupDetail() {
        URNavigationManager.navigation.pushViewController(URGroupDetailsViewController(groupChatRoom: self.chatRoom as! URGroupChatRoom,members:chatMembers), animated: true)
    }
    
    func sendTextMessage(_ text: String!) {
        
        let newMessage = URChatMessage()
        newMessage.user = URUser.activeUser()
        newMessage.message = text
        newMessage.date = NSNumber(value: Int64(Date().timeIntervalSince1970 * 1000) as Int64)
        
        URChatMessageManager.sendChatMessage(newMessage, chatRoom: chatRoom!)
        updateReadMessages()
        
        self.finishSendingMessage()        
    }
    
    func sendMediaMessage(_ media: URMedia!) {
        
        let newMessage = URChatMessage()
        newMessage.user = URUser.activeUser()
        newMessage.media = media
        newMessage.date = NSNumber(value: Int64(Date().timeIntervalSince1970 * 1000) as Int64)
        
        URChatMessageManager.sendChatMessage(newMessage, chatRoom: chatRoom!)
        updateReadMessages()
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            if media.type != URConstant.Media.AUDIO {
                self.mediaSourceViewController.toggleView({ (finish) in })
            }
        }
    }
    
    //MARK: JSQMessagesViewController method overrides
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        if keyboardIsVisible == true {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.sendTextMessage(text)
            finishSendingMessage(animated: true)
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return self.jsqMessages[(indexPath as NSIndexPath).item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didDeleteMessageAt indexPath: IndexPath) {
        self.jsqMessages.remove(at: (indexPath as NSIndexPath).item)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let message = self.jsqMessages[(indexPath as NSIndexPath).item]
        if (message.senderId == senderId) {
            return self.outgoingBubbleImageData
        }
        return self.incomingBubbleImageData
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = self.jsqMessages[(indexPath as NSIndexPath).item]
        if (message.senderId == senderId) {
            if !UserDefaults.outgoingAvatarSetting() {
                return nil
            }
        }else {
            if !UserDefaults.incomingAvatarSetting() {
                return nil
            }
        }
        return self.avatars[message.senderId]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if (indexPath as NSIndexPath).item % 3 == 0 {
        let message: JSQMessage = self.jsqMessages[(indexPath as NSIndexPath).item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = self.jsqMessages[(indexPath as NSIndexPath).item]
        if (message.senderId == senderId) {
            return nil
        }
        if (indexPath as NSIndexPath).item - 1 > 0 {
            let previousMessage = self.jsqMessages[(indexPath as NSIndexPath).item - 1]
            if (previousMessage.senderId == message.senderId) {
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellBottomLabelAt indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    //MARK: UICollectionView DataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.jsqMessages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let msg = self.jsqMessages[(indexPath as NSIndexPath).item]
        if !msg.isMediaMessage {
            if (msg.senderId == senderId) {
                cell.textView!.textColor = UIColor.black
            }
            else {
                cell.textView!.textColor = UIColor.white
            }
            cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView!.textColor!, NSUnderlineStyleAttributeName: [NSUnderlineStyle.styleSingle.rawValue | NSUnderlineStyle.styleNone.rawValue]]
        }
        return cell
    }
    
    //MARK: Adjusting cell label heights
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        let currentMessage = self.jsqMessages[(indexPath as NSIndexPath).item]
        if (currentMessage.senderId == senderId) {
            return 0.0
        }
        if (indexPath as NSIndexPath).item - 1 > 0 {
            let previousMessage = self.jsqMessages[(indexPath as NSIndexPath).item - 1]
            if (previousMessage.senderId == currentMessage.senderId) {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat {
        return 0.0
    }
    
    //MARK: Responding to collection view tap events
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, header headerView: JSQMessagesLoadEarlierHeaderView, didTapLoadEarlierMessagesButton sender: UIButton) {
        NSLog("Load earlier messages!")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapAvatarImageView avatarImageView: UIImageView, at indexPath: IndexPath) {
        NSLog("Tapped avatar!")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        let jsqMessage = self.jsqMessages[(indexPath as NSIndexPath).item]
        
        if jsqMessage.media is URChatVideoItem {
            print("URChatVideoItem tapped")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapCellAt indexPath: IndexPath, touchLocation: CGPoint) {
        NSLog("Tapped cell at %@!", NSStringFromCGPoint(touchLocation))
    }
    
    //MARK: JSQMessagesComposerTextViewPasteDelegate methods
    
    func composerTextView(_ textView: JSQMessagesComposerTextView, shouldPasteWithSender sender: AnyObject) -> Bool {
        if let _ = UIPasteboard.general.image {
//            let item: JSQPhotoMediaItem = JSQPhotoMediaItem(image: UIPasteboard.generalPasteboard().image)
//            let message: URChatMessage = URChatMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: item)
//            self.messages.append(message)
//            finishSendingMessage()
            return false
        }
        return true
    }
    
}

//
//  URAddStoryViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 14/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import SDWebImage

class URAddStoryViewController: UIViewController, URMarkerTableViewControllerDelegate, ISScrollViewPageDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, URMediaViewDelegate {

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtMarkers: UITextField!
    @IBOutlet weak var txtHistory: UITextView!
    @IBOutlet weak var btAddMarkers: UIButton!
    @IBOutlet weak var btAddMedia: UIButton!
    @IBOutlet weak var scrollViewMedias: ISScrollViewPage!
    
    var indexImgCover:Int!
    var mediaViewCover: URMediaView?
    var mediaList:[URMedia] = []
    var actionSheetPicture:UIActionSheet!
    let defaultText = "create_story_insert_story_content".localized
    let maxTitleLength = 80
    var youtubeMediaList:[URMedia]!
    var appDelegate:AppDelegate!
    let markerTableViewController = URMarkerTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        youtubeMediaList = []
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        setupUI()
        setupScrollViewPage()
        setupActionSheet()
        addRightButtonItem()
        markerTableViewController.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pointsScoredDidClosed:", name:"pointsScoredDidClosed", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Story Creation")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    //Mark: Button Events
    
    @IBAction func btSendHistoryTapped(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func btAddMarkersTapped(sender: AnyObject) {
        self.navigationController?.pushViewController(markerTableViewController, animated: true)
    }

    @IBAction func btAddMediaTapped(sender: AnyObject) {
        self.view.endEditing(true)
        actionSheetPicture.showInView(self.view)
    }
    
    //MARK: Class Methods
    
    func pointsScoredDidClosed(notification:NSNotification) {
        URNavigationManager.setFrontViewController(URMainViewController())
    }
    
    func addRightButtonItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "action_title_publish".localized, style: UIBarButtonItemStyle.Done, target: self, action: "buildStory")
    }
    
    func buildStory() {
        
        if let textField = self.view.findTextFieldEmptyInView(self.view) {
            UIAlertView(title: nil, message: String(format: "is_empty".localized, arguments: [textField.placeholder!]), delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        if self.txtHistory.text.isEmpty {
            UIAlertView(title: nil, message: "story_empty".localized, delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        if !scrollViewMedias.views!.isEmpty && indexImgCover == -1 {
            UIAlertView(title: nil, message: "create_story_insert_cover".localized, delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        if !scrollViewMedias.views!.isEmpty {
            ProgressHUD.show(nil)
            
            for i in 0...scrollViewMedias.views!.count-1 {
                
                let mediaView = (scrollViewMedias.views![i] as! URMediaView)
                
                if mediaView.media == nil{
                
                    let img = mediaView.imgMedia.image
                    URAWSManager.uploadImage(img!, uploadPath:.Stories, completion: { (picture:URMedia?) -> Void in
                        if picture != nil {
                            self.mediaList.append(picture!)
                            
                            if (self.mediaList.count + self.youtubeMediaList.count) == self.scrollViewMedias.views!.count {
                                self.saveStory(self.mediaList)
                            }
                            
                        }
                    })
                }else{
                    if (self.mediaList.count + youtubeMediaList.count) == scrollViewMedias.views!.count {
                        self.saveStory(nil)                        
                    }
                }
                
            }
        }else {
            self.saveStory(nil)
        }
    }
    
    func saveStory(medias:[URMedia]?) {
        self.view.endEditing(true)                
        ProgressHUD.show(nil)
        
        let story = URStory()
        
        if medias != nil {
            var m:[URMedia] = medias!
            story.cover = m[indexImgCover]                        
            story.medias =  m
            
            if !youtubeMediaList.isEmpty {
                for media in youtubeMediaList {
                    story.medias.append(media)
                }
            }
        }else{
            if !youtubeMediaList.isEmpty {
                story.medias = youtubeMediaList
                story.cover = youtubeMediaList[indexImgCover]
            }
        }
        
        story.createdDate = NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000))
        story.title = self.txtTitle.text
        story.content = self.txtHistory.text
        story.markers = self.txtMarkers.text
        story.user = URUser.activeUser()!.key
        story.contributions = 0
        
        let isModerator = (URUser.activeUser()!.moderator != nil && URUser.activeUser()!.moderator == true) ||
            (URUser.activeUser()!.masterModerator != nil && URUser.activeUser()!.masterModerator == true)
        
        URStoryManager.saveStory(story, isModerator:isModerator, completion: { (success:Bool) -> Void in
            ProgressHUD.dismiss()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                let alertController: UIAlertController = UIAlertController(title: nil, message: "story_created_info".localized, preferredStyle: .Alert)
                
                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                    self.showPointsScoredViewController()
                }
                
                alertController.addAction(cancelAction)
                
                if isModerator == false {
                    URNavigationManager.navigation.presentViewController(alertController, animated: true, completion: nil)
                }else{
                    self.showPointsScoredViewController()
                }
                
            });
        })
        
    }
    
    func showPointsScoredViewController() {
        let pointsScoredViewController = URPointsScoredViewController(scoreType:.Story)
        pointsScoredViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        URNavigationManager.navigation.presentViewController(pointsScoredViewController, animated: true) { () -> Void in
            UIView.animateWithDuration(0.3) { () -> Void in
                pointsScoredViewController.view.backgroundColor  = UIColor.blackColor().colorWithAlphaComponent(0.5)
            }
        }
    }
    
    func setupActionSheet() {
        actionSheetPicture = UIActionSheet(title: "title_media_source".localized, delegate: self, cancelButtonTitle: "cancel_dialog_button".localized, destructiveButtonTitle: nil, otherButtonTitles: "choose_camera".localized, "choose_picture".localized, "hint_youtube_link".localized)
    }
    
    func setupScrollViewPage() {
        scrollViewMedias.scrollViewPageDelegate = self;
        scrollViewMedias.setFillContent(false)
        scrollViewMedias.setEnableBounces(false)
        scrollViewMedias.setPaging(false)
        scrollViewMedias.scrollViewPageType = ISScrollViewPageType.ISScrollViewPageHorizontally
    }
    
    func setupUI() {
        
        self.txtTitle.text = "create_story_insert_title".localized
        self.txtMarkers.text = "create_story_add_markers".localized
        
        self.txtHistory.text = defaultText
        self.txtHistory.textColor = UIColor.lightGrayColor()
    }
    
    func setupMediaViewWithImage(image:UIImage,media:URMedia?) {
        let viewMedia = NSBundle.mainBundle().loadNibNamed("URMediaView", owner: 0, options: nil)[0] as? URMediaView
        
        if let media = media {
            viewMedia!.media = media
        }
        
        viewMedia!.delegate = self
        viewMedia!.imgMedia.image = image
        scrollViewMedias.addCustomView(viewMedia!)
        
        if scrollViewMedias.views!.count == 1 {
            viewMedia!.isCover = true
            self.mediaViewCover = viewMedia!
            self.mediaViewTapped(viewMedia!)
        }else{
            viewMedia!.isCover = false
        }
    }
    
    //MARK: TextView Delegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == defaultText {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = defaultText
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView == txtTitle{
            return textView.text.characters.count + (text.characters.count - range.length) <= maxTitleLength
        }else {
            return true
        }
    }
    
    //MARK: URMarkerTableViewControllerDelegate
    
    func markersList(markers: [URMarker]) {
                
        var markersString = "\(markers)".stringByReplacingOccurrencesOfString("[", withString: "", options: [], range: nil)
        markersString = "\(markersString)".stringByReplacingOccurrencesOfString("]", withString: "", options: [], range: nil)
        txtMarkers.text = markersString
    }
    
    //MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        switch buttonIndex {
            
        case 0:
            break;
        case 1:
            
            imagePicker.allowsEditing = false;
            imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
            break;
        case 2:
            
            imagePicker.sourceType = .Camera
            imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
            imagePicker.showsCameraControls = true
            imagePicker.allowsEditing = true
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
            break;
            
        case 3:
            
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
                
                self.youtubeMediaList.append(media)
                
                ProgressHUD.show(nil)
                SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.url), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                    
                    }, completed: { (image, error, cacheType, finish, url) -> Void in
                      ProgressHUD.dismiss()
                      self.setupMediaViewWithImage(image,media: media)
                })

            }))

            self.presentViewController(alertControllerTextField, animated: true, completion: nil)
            
            break
        default:
            print("Default")
            break;
            
        }
        
    }
    
    //MARK: URMediaViewDelegate
    
    func mediaViewTapped(mediaView: URMediaView) {
        
        for i in 0...self.scrollViewMedias.views!.count-1 {
            let mView = self.scrollViewMedias.views![i] as! URMediaView
            if mView == mediaView {
                mView.setMediaAsCover(true)
                indexImgCover = i
                print("indexImgCover \(indexImgCover)")
                mediaViewCover = mView
            }else {
                mView.setMediaAsCover(false)
            }
            
        }

    }
    
    func removeMediaView(mediaView: URMediaView) {
        
        for i in 0...self.scrollViewMedias.views!.count-1 {
            let mView = self.scrollViewMedias.views![i] as! URMediaView
   
            if !self.youtubeMediaList.isEmpty {
                for j in 0...self.youtubeMediaList.count-1 {
                    
                    if let media = mView.media {
                        if media == self.youtubeMediaList[j] {
                            self.youtubeMediaList.removeAtIndex(j)
                            break
                        }
                    }
                }
            }
            
        }

        if mediaView.isCover == true {
            mediaViewCover = nil
            indexImgCover = -1
        }
        
        scrollViewMedias.removeCustomView(mediaView)
        
    }
    
    //MARK: ImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setupMediaViewWithImage(pickedImage,media: nil)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    //MARK: ISScrollViewPageDelegate
    
    func scrollViewPageDidChanged(scrollViewPage: ISScrollViewPage, index: Int) {
        
    }
    
}

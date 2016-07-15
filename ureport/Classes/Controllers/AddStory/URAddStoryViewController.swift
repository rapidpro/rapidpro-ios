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

class URAddStoryViewController: UIViewController, URMarkerTableViewControllerDelegate, ISScrollViewPageDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, URMediaViewDelegate, URMediaSourceViewControllerDelegate {

    @IBOutlet weak var lbInsertImage: UILabel!
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
    var videoMediaList:[URMedia]!
    var appDelegate:AppDelegate!
    let markerTableViewController = URMarkerTableViewController()
    let markerViewIPadController = URMarkerViewIPadController()
    let mediaSourceViewController = URMediaSourceViewController()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "URAddStoryViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        youtubeMediaList = []
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        setupUI()
        setupScrollViewPage()
        setupActionSheet()
        addRightButtonItem()
        markerTableViewController.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pointsScoredDidClosed), name:"pointsScoredDidClosed", object: nil)
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
    
    //MARK: Button Events
    
    @IBAction func btSendHistoryTapped(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func btAddMarkersTapped(sender: AnyObject) {
        if URConstant.isIpad {
            markerViewIPadController.viewController = self
            markerViewIPadController.show(true, inViewController: self)
        }else{
            self.navigationController?.pushViewController(markerTableViewController, animated: true)
        }
    }

    @IBAction func btAddMediaTapped(sender: AnyObject) {
        self.view.endEditing(true)
        
        self.view.addSubview(mediaSourceViewController.view)
        mediaSourceViewController.delegate = self
        mediaSourceViewController.toggleView { (finish) -> Void in}
    }
    
    //MARK: MediaSourceViewControllerDelegate

    func newMediaAdded(mediaSourceViewController: URMediaSourceViewController, media: URMedia) {
        setupMediaViewMediaObject(media)
    }

    //MARK: Class Methods

    func pointsScoredDidClosed(notification:NSNotification) {
        URNavigationManager.setFrontViewController(URMainViewController())
    }
    
    func addRightButtonItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "action_title_publish".localized, style: UIBarButtonItemStyle.Done, target: self, action: #selector(buildStory))
    }
    
    func buildStory() {
        
        if let textField = self.view.findTextFieldEmptyInView(self.view) where textField != self.txtMarkers {
            UIAlertView(title: nil, message: String(format: "is_empty".localized, arguments: [textField.placeholder!]), delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        if self.txtHistory.text.isEmpty {
            UIAlertView(title: nil, message: "story_empty".localized, delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        if !self.mediaList.isEmpty {
            
            for media in self.mediaList {
                if (!(media.type == URConstant.Media.AUDIO || media.type == URConstant.Media.FILE) && indexImgCover == nil) {
                    UIAlertView(title: nil, message: "create_story_insert_cover".localized, delegate: self, cancelButtonTitle: "OK").show()
                    return
                }
            }
            
            ProgressHUD.show(nil)
            URMediaUpload.uploadMedias(self.mediaList) { (medias) -> Void in
                ProgressHUD.dismiss()
                self.saveStory(medias)
            }
            
        }else{
            saveStory(nil)
        }
        
    }
    
    func saveStory(medias:[URMedia]?) {
        self.view.endEditing(true)                
        ProgressHUD.show(nil)
        
        let story = URStory()
        
        if let medias = medias {
            story.medias = medias

            for media in medias {
                if media.isCover != nil && media.isCover == true {
                    story.cover = media
                }
                media.isCover = nil
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
                
                let alertController = UIAlertController(title: nil, message: "message_story_publish_warning".localized, preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
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
        actionSheetPicture = UIActionSheet(title: "title_media_source".localized, delegate: self, cancelButtonTitle: "cancel_dialog_button".localized, destructiveButtonTitle: nil, otherButtonTitles: "choose_camera".localized, "choose_take_picture".localized, "hint_youtube_link".localized)
    }
    
    func setupScrollViewPage() {
        scrollViewMedias.scrollViewPageDelegate = self;
        scrollViewMedias.setFillContent(false)
        scrollViewMedias.setEnableBounces(false)
        scrollViewMedias.setPaging(false)
        scrollViewMedias.scrollViewPageType = ISScrollViewPageType.ISScrollViewPageHorizontally
    }
    
    func setupUI() {
        
        self.txtTitle.placeholder = "create_story_insert_title".localized
        self.txtMarkers.placeholder = "create_story_add_markers".localized
        self.lbInsertImage.text = "create_story_title_media".localized
        
        self.txtHistory.text = defaultText
        self.txtHistory.textColor = UIColor.lightGrayColor()
    }
    
    func setupMediaViewMediaObject(media:URMedia) {
        let viewMedia = NSBundle.mainBundle().loadNibNamed("URMediaView", owner: 0, options: nil)[0] as! URMediaView
        
        viewMedia.setupWithMediaObject(media)
        viewMedia.delegate = self
        
        scrollViewMedias.addCustomView(viewMedia)
        
        if scrollViewMedias.views!.count == 1 && !(media.type == URConstant.Media.AUDIO || media.type == URConstant.Media.FILE){
            indexImgCover = 0
            viewMedia.isCover = true
            self.mediaViewCover = viewMedia
            self.mediaViewTapped(viewMedia)
        }else{
            viewMedia.isCover = false
        }
        
        self.mediaList.append(media)
        
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
    
    //MARK: URMediaViewDelegate
    
    func mediaViewTapped(mediaView: URMediaView) {
        
        for i in 0...self.scrollViewMedias.views!.count-1 {
            let mView = self.scrollViewMedias.views![i] as! URMediaView
            if mView == mediaView {
                indexImgCover = 0
                mView.setMediaAsCover(true)
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
            let imageMedia = URImageMedia()
            imageMedia.image = pickedImage
            setupMediaViewMediaObject(imageMedia)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    //MARK: ISScrollViewPageDelegate
    
    func scrollViewPageDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewPageDidChanged(scrollViewPage: ISScrollViewPage, index: Int) {
        
    }
    
}

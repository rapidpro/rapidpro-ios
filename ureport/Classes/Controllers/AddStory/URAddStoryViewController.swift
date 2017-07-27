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
import MBProgressHUD
import ISScrollViewPageSwift

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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "URAddStoryViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        youtubeMediaList = []
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        setupUI()
        setupScrollViewPage()
        setupActionSheet()
        addRightButtonItem()
        markerTableViewController.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(pointsScoredDidClosed), name:NSNotification.Name(rawValue: "pointsScoredDidClosed"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Story Creation")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
    }
    
    //MARK: Button Events
    
    @IBAction func btSendHistoryTapped(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func btAddMarkersTapped(_ sender: AnyObject) {
        if URConstant.isIpad {
            markerViewIPadController.viewController = self
            markerViewIPadController.show(true, inViewController: self)
        }else{
            self.navigationController?.pushViewController(markerTableViewController, animated: true)
        }
    }

    @IBAction func btAddMediaTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        
        self.view.addSubview(mediaSourceViewController.view)
        mediaSourceViewController.delegate = self
        mediaSourceViewController.toggleView { (finish) -> Void in}
    }
    
    //MARK: MediaSourceViewControllerDelegate

    func newMediaAdded(_ mediaSourceViewController: URMediaSourceViewController, media: URMedia) {
        setupMediaViewMediaObject(media)
    }

    //MARK: Class Methods

    func pointsScoredDidClosed(_ notification:Notification) {
        URNavigationManager.setFrontViewController(URMainViewController())
    }
    
    func addRightButtonItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "action_title_publish".localized, style: UIBarButtonItemStyle.done, target: self, action: #selector(buildStory))
    }
    
    func buildStory() {
        
        if let textField = self.view.findTextFieldEmptyInView(self.view) , textField != self.txtMarkers {
            UIAlertView(title: nil, message: String(format: "is_empty".localized, arguments: [textField.placeholder!]), delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        if self.txtHistory.text.isEmpty {
            UIAlertView(title: nil, message: "story_empty".localized, delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        MBProgressHUD.showAdded(to: self.view.window!, animated: true)
        
        if !self.mediaList.isEmpty {
            
            for media in self.mediaList {
                if (!(media.type == URConstant.Media.AUDIO || media.type == URConstant.Media.FILE) && indexImgCover == nil) {
                    UIAlertView(title: nil, message: "create_story_insert_cover".localized, delegate: self, cancelButtonTitle: "OK").show()
                    return
                }
            }
            
            URMediaUpload.uploadMedias(self.mediaList) { (medias) -> Void in
                self.saveStory(medias)
            }
            
        }else{
            saveStory(nil)
        }
        
    }
    
    func saveStory(_ medias:[URMedia]?) {
        self.view.endEditing(true)                
        
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
        
        story.createdDate = NSNumber(value: Int64(Date().timeIntervalSince1970 * 1000) as Int64)
        story.title = self.txtTitle.text
        story.content = self.txtHistory.text
        story.markers = self.txtMarkers.text
        story.user = URUser.activeUser()!.key
        story.contributions = 0
        
        let isModerator = (URUser.activeUser()!.moderator != nil && URUser.activeUser()!.moderator == true) ||
            (URUser.activeUser()!.masterModerator != nil && URUser.activeUser()!.masterModerator == true)
        
        URStoryManager.saveStory(story, isModerator:isModerator, completion: { (success:Bool) -> Void in
            MBProgressHUD.hide(for: self.view.window!, animated: true)
            
            DispatchQueue.main.async(execute: {
                
                let alertController = UIAlertController(title: nil, message: "message_story_publish_warning".localized, preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in
                    self.showPointsScoredViewController()
                }
                
                alertController.addAction(cancelAction)
                
                if isModerator == false {
                    URNavigationManager.navigation.present(alertController, animated: true, completion: nil)
                }else{
                    self.showPointsScoredViewController()
                }
                
            });
        })
        
    }
    
    func showPointsScoredViewController() {
        let pointsScoredViewController = URPointsScoredViewController(scoreType:.story)
        pointsScoredViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        URNavigationManager.navigation.present(pointsScoredViewController, animated: true) { () -> Void in
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                pointsScoredViewController.view.backgroundColor  = UIColor.black.withAlphaComponent(0.5)
            }) 
        }
    }
    
    func setupActionSheet() {
        actionSheetPicture = UIActionSheet(title: "title_media_source".localized, delegate: self, cancelButtonTitle: "cancel_dialog_button".localized, destructiveButtonTitle: nil, otherButtonTitles: "choose_camera".localized, "choose_take_picture".localized, "hint_youtube_link".localized)
    }
    
    func setupScrollViewPage() {
        scrollViewMedias.scrollViewPageDelegate = self
        scrollViewMedias.setFillContent(false)
        scrollViewMedias.setEnableBounces(false)
        scrollViewMedias.setPaging(false)
        scrollViewMedias.scrollViewPageType = ISScrollViewPageType.horizontally
    }
    
    func setupUI() {
        
        self.txtTitle.placeholder = "create_story_insert_title".localized
        self.txtMarkers.placeholder = "create_story_add_markers".localized
        self.lbInsertImage.text = "create_story_title_media".localized
        
        self.txtHistory.text = defaultText
        self.txtHistory.textColor = UIColor.lightGray
    }
    
    func setupMediaViewMediaObject(_ media:URMedia) {
        let viewMedia = Bundle.main.loadNibNamed("URMediaView", owner: 0, options: nil)?[0] as! URMediaView
        
        viewMedia.setupWithMediaObject(media)
        viewMedia.delegate = self
        
        scrollViewMedias.addCustomView(viewMedia)
        
        if scrollViewMedias.views.count == 1 && !(media.type == URConstant.Media.AUDIO || media.type == URConstant.Media.FILE){
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == defaultText {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = defaultText
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView == txtTitle{
            return textView.text.characters.count + (text.characters.count - range.length) <= maxTitleLength
        }else {
            return true
        }
    }
    
    //MARK: URMarkerTableViewControllerDelegate
    
    func markersList(_ markers: [URMarker]) {
                
        var markersString = "\(markers)".replacingOccurrences(of: "[", with: "", options: [], range: nil)
        markersString = "\(markersString)".replacingOccurrences(of: "]", with: "", options: [], range: nil)
        txtMarkers.text = markersString
    }
    
    //MARK: URMediaViewDelegate
    
    func mediaViewTapped(_ mediaView: URMediaView) {
        
        for i in 0...self.scrollViewMedias.views.count-1 {
            let mView = self.scrollViewMedias.views[i] as! URMediaView
            if mView == mediaView {
                indexImgCover = 0
                mView.setMediaAsCover(true)
                mediaViewCover = mView
            }else {
                mView.setMediaAsCover(false)
            }
            
        }

    }
    
    func removeMediaView(_ mediaView: URMediaView) {
        
        for i in 0...self.scrollViewMedias.views.count-1 {
            let mView = self.scrollViewMedias.views[i] as! URMediaView
   
            if !self.youtubeMediaList.isEmpty {
                for j in 0...self.youtubeMediaList.count-1 {
                    
                    if let media = mView.media {
                        if media == self.youtubeMediaList[j] {
                            self.youtubeMediaList.remove(at: j)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageMedia = URImageMedia()
            imageMedia.image = pickedImage
            setupMediaViewMediaObject(imageMedia)
        }
        
        self.dismiss(animated: true, completion: nil)

    }
    
    //MARK: ISScrollViewPageDelegate
    
    func scrollViewPageDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewPageDidChanged(_ scrollViewPage: ISScrollViewPage, index: Int) {
        
    }
    
}

//
//  URAddStoryViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 14/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

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
    let defaultText = "Tell us what's going on".localized
    let maxTitleLength = 80
    
    var appDelegate:AppDelegate!
    let markerTableViewController = URMarkerTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: UIBarButtonItemStyle.Done, target: self, action: "buildStory")
    }
    
    func buildStory() {
        
        if let textField = self.view.findTextFieldEmptyInView(self.view) {
            UIAlertView(title: nil, message: "\(textField.placeholder!) is empty", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        if self.txtHistory.text.isEmpty {
            UIAlertView(title: nil, message: "What is your story?", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        if !scrollViewMedias.views!.isEmpty && indexImgCover == -1 {
            UIAlertView(title: nil, message: "Please select one picture to put as cover!", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        if !scrollViewMedias.views!.isEmpty {
            ProgressHUD.show(nil)
            
            for i in 0...scrollViewMedias.views!.count-1 {
                let img = (scrollViewMedias.views![i] as! URMediaView).imgMedia.image
                URAWSManager.uploadImage(img!, uploadPath:.Stories, completion: { (picture:URMedia?) -> Void in
                    if picture != nil {
                        self.mediaList.append(picture!)
                        
                        if self.scrollViewMedias.views!.count == self.mediaList.count {
                            self.saveStory(self.mediaList)
                        }
                        
                    }
                })
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
                
                let alertController: UIAlertController = UIAlertController(title: nil, message: "Your story has been subimitted to the U-Report team. Check back soon to see it published", preferredStyle: .Alert)
                
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
        actionSheetPicture = UIActionSheet(title: "Choose an option above", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Choose from Camera roll", "Take a Picture")
    }
    
    func setupScrollViewPage() {
        scrollViewMedias.scrollViewPageDelegate = self;
        scrollViewMedias.setFillContent(false)
        scrollViewMedias.setEnableBounces(false)
        scrollViewMedias.setPaging(false)
        scrollViewMedias.scrollViewPageType = ISScrollViewPageType.ISScrollViewPageHorizontally
    }
    
    func setupUI() {
        self.txtHistory.text = defaultText
        self.txtHistory.textColor = UIColor.lightGrayColor()
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
            print("cancel")
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
        
        scrollViewMedias.removeCustomView(mediaView)
        
        if mediaView.isCover == true {
            mediaViewCover = nil
            indexImgCover = -1
        }
    }
    
    //MARK: ImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let viewMedia = NSBundle.mainBundle().loadNibNamed("URMediaView", owner: 0, options: nil)[0] as? URMediaView
        viewMedia!.delegate = self
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            viewMedia!.imgMedia.image = pickedImage
            scrollViewMedias.addCustomView(viewMedia!)
            
            if scrollViewMedias.views!.count == 1 {
                self.mediaViewCover = viewMedia!
                self.mediaViewTapped(viewMedia!)
            }
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    //MARK: ISScrollViewPageDelegate
    
    func scrollViewPageDidChanged(scrollViewPage: ISScrollViewPage, index: Int) {
        
    }
    
}

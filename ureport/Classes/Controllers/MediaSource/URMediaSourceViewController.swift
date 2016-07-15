//
//  URMediaSourceViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 21/01/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import SDWebImage
import MobileCoreServices
import Proposer

protocol URMediaSourceViewControllerDelegate {
    func newMediaAdded(mediaSourceViewController:URMediaSourceViewController, media:URMedia)
}

class URMediaSourceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, URAudioRecorderViewControllerDelegate {
    
    @IBOutlet weak var btCamera: ISCircleButton!
    @IBOutlet weak var btGallery: ISCircleButton!
    @IBOutlet weak var btVideo: ISCircleButton!
    @IBOutlet weak var btFile: ISCircleButton!
    @IBOutlet weak var btAudio: ISCircleButton!
    @IBOutlet weak var btYoutube: ISCircleButton!
    
    @IBOutlet weak var btDismiss: UIButton!
    
    @IBOutlet weak var lbCamera: UILabel!
    @IBOutlet weak var lbGallery: UILabel!
    @IBOutlet weak var lbVideo: UILabel!
    @IBOutlet weak var lbFile: UILabel!
    @IBOutlet weak var lbAudio: UILabel!
    @IBOutlet weak var lbYoutube: UILabel!
    
    var media:URMedia!
    var image:UIImage!
    
    var isVisible:Bool!
    
    var delegate:URMediaSourceViewControllerDelegate?
    
    init() {
        if !URConstant.isIpad {
            super.init(nibName: "URMediaSourceViewController", bundle: nil)
        }else{
            super.init(nibName: "URMediaSourceViewIPadController", bundle: nil)
        }
        isVisible = false
        
        let frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.size.height, width: UIScreen.mainScreen().bounds.size.width, height: self.view.frame.size.height)
        self.view.frame = frame
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lbAudio.text = "audio".localized
        self.lbCamera.text = "camera".localized
        self.lbFile.text = "file".localized
        self.lbGallery.text = "gallery".localized
        self.lbVideo.text = "video".localized
        self.lbYoutube.text = "Youtube"
        
    }

    //MARK: Class Methods
    
    func toggleView(animationFinish:(finish:Bool!) -> Void) {

        if !isVisible {
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                let frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
                self.view.frame = frame
                }) { (finish) -> Void in
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.btDismiss.layer.opacity = 0.5
                        }, completion: { (finish) -> Void in
                            self.isVisible = true
                            animationFinish(finish: true)
                    })
            }
        }else{

            UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.btDismiss.layer.opacity = 0
                }) { (finish) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        let frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.size.height, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
                        self.view.frame = frame
                        }, completion: { (finish:Bool) -> Void in
                            self.isVisible = false
                            animationFinish(finish: true)
                    })
            }
        }
        
    }
    
    //MARK: UIDocumentPickerDelegate
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        
        if let delegate = self.delegate {
            
            let media = URLocalMedia()
            media.metadata = ["filename":url.lastPathComponent!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String]
            media.path = url.path!
            media.type = URConstant.Media.FILE
            
            delegate.newMediaAdded(self, media: media)
        }
        
    }
    
    
    //MARK: ImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if let delegate = delegate {
        
            if mediaType == kUTTypeMovie {
                let mediaURL = (info[UIImagePickerControllerMediaURL] as! NSURL)
                let path = mediaURL.path
                
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path!) {}
                
                let media = URVideoPhoneMedia()
                media.path = path
                media.thumbnailImage = URVideoUtil.generateThumbnail(mediaURL)
                media.type = URConstant.Media.VIDEOPHONE
                
                delegate.newMediaAdded(self, media: media)
                
            }else {
                
                if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    
                    let media = URImageMedia()
                    media.type = URConstant.Media.PICTURE
                    media.image = pickedImage
                    
                    delegate.newMediaAdded(self, media: media)
                }
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: AudioRecorderViewControllerDelegate
    
    func newAudioRecorded(audioRecorderViewController: URAudioRecorderViewController, media: URMedia) {
        if let delegate = delegate {
            media.type = URConstant.Media.AUDIO
            delegate.newMediaAdded(self, media: media)
        }
    }
    
    //MARK: Button Events
    
    @IBAction func btDismissTapped(sender: AnyObject) {
        self.toggleView { (finish) -> Void in }
    }
    
    @IBAction func btMediaSourceTapped(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        switch sender as! ISCircleButton {
         
        case btCamera:
            
            proposeToAccess(PrivateResource.Camera, agreed: {
                
                imagePicker.sourceType = .Camera
                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                imagePicker.showsCameraControls = true
                imagePicker.allowsEditing = true
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
                
                }, rejected: {
                    self.alertNoPermissionToAccess(PrivateResource.Camera)
            })
            
            break
            
        case btGallery:
            
            proposeToAccess(PrivateResource.Photos, agreed: {
                
                imagePicker.allowsEditing = false;
                imagePicker.sourceType = .PhotoLibrary
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
                
                }, rejected: {
                    self.alertNoPermissionToAccess(PrivateResource.Photos)
            })
            
            break
            
        case btVideo:
            
            proposeToAccess(PrivateResource.Camera, agreed: {
            
                imagePicker.sourceType = .Camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.videoQuality = .Type640x480
                imagePicker.videoMaximumDuration = 20
                
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
                
                }, rejected: {
                    self.alertNoPermissionToAccess(PrivateResource.Camera)
            })
            
            break
            
        case btFile:
            
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], inMode: .Import)
            documentPicker.delegate = self
            self.presentViewController(documentPicker, animated: true, completion: nil)
            
            break
            
        case btAudio:
            
            let audioRecorderViewController = URAudioRecorderViewController(audioURL: nil)
            audioRecorderViewController.delegate = self
            
            self.toggleView({ (finish) -> Void in })
            
            audioRecorderViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            URNavigationManager.navigation.presentViewController(audioRecorderViewController, animated: true) { () -> Void in
                UIView.animateWithDuration(0.3) { () -> Void in
                    audioRecorderViewController.view.backgroundColor  = UIColor.blackColor().colorWithAlphaComponent(0.5)
                }
            }
            
            break
            
        case btYoutube:
            
            let alertControllerTextField = UIAlertController(title: nil, message: "message_youtube_link".localized, preferredStyle: UIAlertControllerStyle.Alert)
            
            alertControllerTextField.addTextFieldWithConfigurationHandler(nil)
            alertControllerTextField.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: .Cancel, handler: nil))
            alertControllerTextField.addAction(UIAlertAction(title: "sign_up_confirm".localized, style: .Default, handler: { (alertAction) -> Void in
                
                let urlVideo = alertControllerTextField.textFields![0].text!
                
                if urlVideo.isEmpty {
                    UIAlertView(title: nil, message: "error_empty_link".localized, delegate: self, cancelButtonTitle: "OK").show()
                    return
                }
                
                guard let videoID = URYoutubeUtil.getYoutubeVideoID(urlVideo) else {
                    UIAlertView(title: nil, message: "error_empty_link".localized, delegate: self, cancelButtonTitle: "OK").show()
                    return
                }
                
                let media = URVideoMedia()
                
                media.id = videoID
                media.url = URConstant.Youtube.COVERIMAGE.stringByReplacingOccurrencesOfString("%@", withString: media.id)
                media.type = URConstant.Media.VIDEO
                
                if let delegate = self.delegate {
                    delegate.newMediaAdded(self, media: media)
                }
                
            }))
            
            self.presentViewController(alertControllerTextField, animated: true, completion: nil)
            
            break
            
        default:
            break
            
        }
        
    }
    
}

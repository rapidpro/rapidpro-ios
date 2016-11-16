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
    func newMediaAdded(_ mediaSourceViewController:URMediaSourceViewController, media:URMedia)
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
        
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: self.view.frame.size.height)
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
    
    func toggleView(_ animationFinish:@escaping (_ finish:Bool?) -> Void) {

        if !isVisible {
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                self.view.frame = frame
                }, completion: { (finish) -> Void in
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.btDismiss.layer.opacity = 0.5
                        }, completion: { (finish) -> Void in
                            self.isVisible = true
                            animationFinish(true)
                    })
            }) 
        }else{

            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.btDismiss.layer.opacity = 0
                }, completion: { (finish) -> Void in
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        let frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        self.view.frame = frame
                        }, completion: { (finish:Bool) -> Void in
                            self.isVisible = false
                            animationFinish(true)
                    })
            }) 
        }
        
    }
    
    //MARK: UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        if let delegate = self.delegate {
            
            let media = URLocalMedia()
            media.metadata = ["filename":url.lastPathComponent.replacingOccurrences(of: " ", with: "_") as String as AnyObject]
            media.path = url.path
            media.type = URConstant.Media.FILE
            
            delegate.newMediaAdded(self, media: media)
        }
        
    }
    
    
    //MARK: ImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if let delegate = delegate {
        
            if mediaType == kUTTypeMovie {
                let mediaURL = (info[UIImagePickerControllerMediaURL] as! URL)
                let path = mediaURL.path
                
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {}
                
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
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: AudioRecorderViewControllerDelegate
    
    func newAudioRecorded(_ audioRecorderViewController: URAudioRecorderViewController, media: URMedia) {
        if let delegate = delegate {
            media.type = URConstant.Media.AUDIO
            delegate.newMediaAdded(self, media: media)
        }
    }
    
    //MARK: Button Events
    
    @IBAction func btDismissTapped(_ sender: AnyObject) {
        self.toggleView { (finish) -> Void in }
    }
    
    @IBAction func btMediaSourceTapped(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        switch sender as! ISCircleButton {
         
        case btCamera:
            
            proposeToAccess(PrivateResource.camera, agreed: {
                
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.photo
                imagePicker.showsCameraControls = true
                imagePicker.allowsEditing = true
                
                self.present(imagePicker, animated: true, completion: nil)
                
                }, rejected: {
                    self.alertNoPermissionToAccess(PrivateResource.camera)
            })
            
            break
            
        case btGallery:
            
            proposeToAccess(PrivateResource.photos, agreed: {
                
                imagePicker.allowsEditing = false;
                imagePicker.sourceType = .photoLibrary
                
                self.present(imagePicker, animated: true, completion: nil)
                
                }, rejected: {
                    self.alertNoPermissionToAccess(PrivateResource.photos)
            })
            
            break
            
        case btVideo:
            
            proposeToAccess(PrivateResource.camera, agreed: {
            
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.videoQuality = .type640x480
                imagePicker.videoMaximumDuration = 20
                
                imagePicker.allowsEditing = false
                
                self.present(imagePicker, animated: true, completion: nil)
                
                }, rejected: {
                    self.alertNoPermissionToAccess(PrivateResource.camera)
            })
            
            break
            
        case btFile:
            
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
            
            break
            
        case btAudio:
            
            let audioRecorderViewController = URAudioRecorderViewController(audioURL: nil)
            audioRecorderViewController.delegate = self
            
            self.toggleView({ (finish) -> Void in })
            
            audioRecorderViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            URNavigationManager.navigation.present(audioRecorderViewController, animated: true) { () -> Void in
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    audioRecorderViewController.view.backgroundColor  = UIColor.black.withAlphaComponent(0.5)
                }) 
            }
            
            break
            
        case btYoutube:
            
            let alertControllerTextField = UIAlertController(title: nil, message: "message_youtube_link".localized, preferredStyle: UIAlertControllerStyle.alert)
            
            alertControllerTextField.addTextField(configurationHandler: nil)
            alertControllerTextField.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: .cancel, handler: nil))
            alertControllerTextField.addAction(UIAlertAction(title: "sign_up_confirm".localized, style: .default, handler: { (alertAction) -> Void in
                
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
                media.url = URConstant.Youtube.COVERIMAGE.replacingOccurrences(of: "%@", with: media.id!)
                media.type = URConstant.Media.VIDEO
                
                if let delegate = self.delegate {
                    delegate.newMediaAdded(self, media: media)
                }
                
            }))
            
            self.present(alertControllerTextField, animated: true, completion: nil)
            
            break
            
        default:
            break
            
        }
        
    }
    
}

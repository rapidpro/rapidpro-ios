//
//  URStoryContributionViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 16/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import NYTPhotoViewer
import youtube_ios_player_helper
import SDWebImage
import MediaPlayer

class URStoryContributionViewController: UIViewController, URContributionManagerDelegate, NYTPhotosViewControllerDelegate, URStoryContributionTableViewCellDelegate {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbMarkers: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewMedias: ISScrollViewPage!
    @IBOutlet weak var lbContributions: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtContribute: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var contributionView: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewMediaHeight: NSLayoutConstraint!
    @IBOutlet weak var lbContentHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    let contributionManager = URContributionManager()
    
    var listContribution:[URContribution] = []
    var story:URStory!
    var photos:[PhotoShow] = []
    var photosViewController:NYTPhotosViewController!
    
    init(story:URStory) {
        super.init(nibName: "URStoryContributionViewController", bundle: nil)
        self.story = story
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStory()
        setupTableView()
        setupScrollView()
        setupScrollViewMedias()
        self.title = story.userObject!.nickname
        contributionManager.getContributions(story.key)
        contributionManager.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithType(.Clear)
        URNavigationManager.navigation.followScrollView(self.scrollView, delay: 50.0)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Story Detail")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        URNavigationManager.navigation.stopFollowingScrollView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.lbContent.setSizeFont(14)
        
        if story.medias == nil {
            self.scrollViewMediaHeight.constant = 0
        }
        
        var scrollViewHeight = self.lbContent.frame.size.height + self.contributionView.frame.height + self.topView.frame.size.height + self.scrollViewMedias.frame.height + 70

        self.tableViewHeight.constant = self.tableView.contentSize.height
        scrollViewHeight = scrollViewHeight + self.tableView.contentSize.height
        
        self.contentViewHeight.constant = scrollViewHeight
        self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width,scrollViewHeight)
        
        self.view.layoutIfNeeded()
    }
    
    //MARK: Class Methods
    
    func setupStory() {
        
        self.lbContributions.text = String(format: "stories_list_item_contributions".localized, arguments: [0])
        self.txtContribute.placeholder = "story_item_contribute_to_story".localized
        self.lbTitle.text = story.title
        self.lbMarkers.text = story.markers
        self.lbContent.text = story.content
        
        if story.userObject!.picture == nil{
            self.imgProfile.contentMode = UIViewContentMode.Center
            self.imgProfile.image = UIImage(named: "ic_person")
            
            self.roundedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        }else{
            self.imgProfile.sd_setImageWithURL(NSURL(string: story.userObject!.picture))
        }
        
    }
    
    func setupTableView() {
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerNib(UINib(nibName: "URStoryContributionTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URStoryContributionTableViewCell.self))
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 68.0
    }

    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listContribution.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URStoryContributionTableViewCell.self), forIndexPath: indexPath) as! URStoryContributionTableViewCell
        
        cell.setupCellWith(self.listContribution[indexPath.row], indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: Class Methods
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setupScrollViewMedias() {
        
        scrollViewMedias.setFillContent(false)
        scrollViewMedias.setEnableBounces(false)
        scrollViewMedias.setPaging(false)
        scrollViewMedias.scrollViewPageType = ISScrollViewPageType.ISScrollViewPageHorizontally
        
        if story.medias != nil && story.medias.count > 0 {
            var photoIndex = 0
            
            for media in story.medias {
                
                if media.type == URConstant.Media.PICTURE {
                    
                    let playMediaView = URPlayMediaView()
                    playMediaView.setupViewWithMedia(media)
                    playMediaView.backgroundColor = UIColor.blackColor()
                    
                    self.scrollViewMedias.addCustomView(playMediaView)
                    
//                    let tapGesture = UITapGestureRecognizer(target: self, action: "imgViewTapped:")
//                    tapGesture.numberOfTouchesRequired = 1
//    
//                    imgView.addGestureRecognizer(tapGesture)
    
//                    imgView.sd_setImageWithURL(NSURL(string:media.url), completed: { (image, _, _, _) -> Void in
//                        
//
//                        
//                        self.scrollViewMedias.addCustomView(playMediaView)
//    
//                        let title = NSAttributedString(string: "Photo", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
//                        let photo = PhotoShow(image: imgView.image, attributedCaptionTitle: title)
//                        photo.index = photoIndex
//                        
//                        self.photos.append(photo)
//                        photoIndex++
//                    })
                    
                } else if media.type == URConstant.Media.VIDEO {
                    
//                    let playerView = YTPlayerView(frame: frame)
//                    playerView.loadWithVideoId(media.id)
//                    
//                    let playMediaView = URPlayMediaView()
//                    playMediaView.frame = frame
//                    playMediaView.media = media
//                    playMediaView.addSubview(playerView)
//                    playMediaView.tag = photoIndex
//                    
//                    self.scrollViewMedias.addCustomView(playMediaView)
                    
                    let playMediaView = URPlayMediaView()
                    playMediaView.setupViewWithMedia(media)
                    self.scrollViewMedias.addCustomView(playMediaView)
                    
//                    SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.url), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
//                        
//                        }, completed: { (image, error, cacheType, finish, url) -> Void in
//                            
//                            let title = NSAttributedString(string: "Youtube", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
//                            let photo = PhotoShow(image: image, attributedCaptionTitle: title)
//                            photo.index = photoIndex
//                            
//                            self.photos.append(photo)
//                            photoIndex++
//                            
//                    })
                    
                } else if media.type == URConstant.Media.VIDEOPHONE {
                    
                    let playMediaView = URPlayMediaView()
                    playMediaView.setupViewWithMedia(media)
                    self.scrollViewMedias.addCustomView(playMediaView)
                    
//                    let playMediaView = URPlayMediaView()
//                    playMediaView.frame = frame
//                    playMediaView.media = media
//                    playMediaView.tag = photoIndex
//                    
//                    let url = NSURL(string: media.url)!
//                    
//                    let moviePlayer = MPMoviePlayerController(contentURL: url)
//                    
//                    moviePlayer.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//                    moviePlayer.shouldAutoplay = true
//                    moviePlayer.controlStyle = .Default
//                    
//                    playMediaView.addSubview(moviePlayer.view)
//                    
//                    self.scrollViewMedias.addCustomView(playMediaView)
//                    moviePlayer.setFullscreen(true, animated: true)
//                    
//                    SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.thumbnail), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
//                        
//                        }, completed: { (image, error, cacheType, finish, url) -> Void in
//                            
//                            let title = NSAttributedString(string: "Video", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
//                            let photo = PhotoShow(image: image, attributedCaptionTitle: title)
//                            photo.index = photoIndex
//                            
//                            self.photos.append(photo)
//                            photoIndex++
//                            
//                    })
                    
                }
                
            }
        }
    }
    
    func setupScrollView() {
        self.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
    }
    
    func imgViewTapped(sender:UITapGestureRecognizer) {
        
        photosViewController = NYTPhotosViewController(photos: self.photos, initialPhoto:self.photos[sender.view!.tag])
        photosViewController.delegate = self
        
        presentViewController(photosViewController, animated: true) { () -> Void in
           UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        }
        
    }
    
    //MARK: URStoryContributionTableViewCellDelegate
    
    func contributionTableViewCellDeleteButtonTapped(cell: URStoryContributionTableViewCell) {
        
        let alert = UIAlertController(title: nil, message: "message_remove_chat_message".localized, preferredStyle: UIAlertControllerStyle.ActionSheet)

        alert.addAction(UIAlertAction(title: "label_remove".localized, style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            let indexPath = self.tableView.indexPathForCell(cell)!
            self.listContribution.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            let totalContributions = Int(self.story.contributions) - 1
            self.lbContributions.text = String(format: "stories_list_item_contributions".localized, arguments: [totalContributions])
            
            self.tableView.contentSize.height = CGFloat(totalContributions)
            URContributionManager.removeContribution(self.story.key, contributionKey: cell.contribution.key)
            
            self.view.layoutIfNeeded()
            
        }))

        alert.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: UIAlertActionStyle.Cancel, handler:nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //MARK: ContributionManagerDelegate
    
    func newContributionReceived(contribution: URContribution) {
        listContribution.append(contribution)
        self.lbContributions.text = String(format: "stories_list_item_contributions".localized, arguments: [listContribution.count])
        tableView.reloadData()
    }
    
    
    //MARK: TextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if !textField.text!.isEmpty{
            
            let user = URUser()
            user.key = URUser.activeUser()!.key
            
            let contribution = URContribution()
            contribution.content = textField.text!
            contribution.author = user
            contribution.createdDate = NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000))
            
            URContributionManager.saveContribution(story.key, contribution: contribution, completion: { (success) -> Void in
                URUserManager.incrementUserContributions(user.key)
                textField.text = ""
                textField.resignFirstResponder()
            })
        }
        
        return true
    }

    override func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if let _ = URUser.activeUser() {
            return true
        }else {
            URLoginAlertController.show(self)
            return false
        }
    }
    
    // MARK: - NYTPhotosViewControllerDelegate
    
    func photosViewController(photosViewController: NYTPhotosViewController!, didDisplayPhoto photo: NYTPhoto!, atIndex photoIndex: UInt) {

    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, handleActionButtonTappedForPhoto photo: NYTPhoto!) -> Bool {
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            let shareActivityViewController = UIActivityViewController(activityItems: [photo.image], applicationActivities: nil)
            
            shareActivityViewController.completionWithItemsHandler = { (activity, success, items, error) in
                if success {
                    photosViewController.delegate?.photosViewController!(photosViewController, actionCompletedWithActivityType: activity)
                }
            }
            
            shareActivityViewController.popoverPresentationController?.barButtonItem = photosViewController.rightBarButtonItem
            photosViewController.presentViewController(shareActivityViewController, animated: true, completion: nil)
            
            return true
        }
        
        return false
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, referenceViewForPhoto photo: NYTPhoto!) -> UIView! {
        if photo as? PhotoShow == photos[0] {
            /** Swift 1.2
            *  if photo as! ExamplePhoto == photos[PhotosProvider.NoReferenceViewPhotoIndex]
            */
            return nil
        }
        return nil
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, loadingViewForPhoto photo: NYTPhoto!) -> UIView! {
        if let _ = photo as? PhotoShow {
            let label = UILabel()
//            label.text = "Custom Loading..."
//            label.textColor = UIColor.greenColor()
            return label
        }
        return nil
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, captionViewForPhoto photo: NYTPhoto!) -> UIView! {
        if let _ = photo as? PhotoShow {
            let label = UILabel()
            label.text = photo.attributedCaptionTitle.string
            label.textColor = UIColor.whiteColor()
            label.backgroundColor = UIColor.clearColor()
            return label
        }
        return nil
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, didNavigateToPhoto photo: NYTPhoto!, atIndex photoIndex: UInt) {
        print("Did Navigate To Photo: \(photo) identifier: \(photoIndex)")
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController!, actionCompletedWithActivityType activityType: String!) {
        print("Action Completed With Activity Type: \(activityType)")
    }
    
    func photosViewControllerDidDismiss(photosViewController: NYTPhotosViewController!) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
    }
    
}

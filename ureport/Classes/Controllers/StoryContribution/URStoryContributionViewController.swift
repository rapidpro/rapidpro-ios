//
//  URStoryContributionViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 16/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class URStoryContributionViewController: UIViewController, URContributionManagerDelegate, NYTPhotosViewControllerDelegate, URStoryContributionTableViewCellDelegate {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbMarkers: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewMedias: ISScrollViewPage!
    @IBOutlet weak var lbContributions: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topView: UIView!
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
    var photoIndexTapped = 0
    
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
        self.title = story.userObject.nickname
        contributionManager.getContributions(story.key)
        contributionManager.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithType(.Clear)
        URNavigationManager.navigation.followScrollView(self.scrollView, delay: 50.0)
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
        
        var scrollViewHeight = self.lbContent.frame.size.height + self.contributionView.frame.height + self.topView.frame.size.height + self.scrollViewMedias.frame.height + 45

        self.tableViewHeight.constant = self.tableView.contentSize.height
        scrollViewHeight = scrollViewHeight + self.tableView.contentSize.height
        
        self.contentViewHeight.constant = scrollViewHeight
        self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width,scrollViewHeight)
        
        self.view.layoutIfNeeded()
    }
    
    //MARK: Class Methods
    
    func setupStory() {
        self.lbTitle.text = story.title
        self.lbMarkers.text = story.markers
        self.lbContent.text = story.content
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
    
    func setupScrollViewMedias() {
        
        scrollViewMedias.setFillContent(false)
        scrollViewMedias.setEnableBounces(false)
        scrollViewMedias.setPaging(false)
        scrollViewMedias.scrollViewPageType = ISScrollViewPageType.ISScrollViewPageHorizontally
        
        if story.medias != nil && story.medias.count > 0{
            var photoIndex = 0
            
            for media in story.medias {
                
                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 115))
                imgView.layer.borderWidth = 2
                imgView.layer.borderColor = UIColor.whiteColor().CGColor
                imgView.contentMode = UIViewContentMode.ScaleAspectFill
                imgView.userInteractionEnabled = true
                
                let tapGesture = UITapGestureRecognizer(target: self, action: "imgViewTapped:")
                tapGesture.numberOfTouchesRequired = 1
                
                imgView.addGestureRecognizer(tapGesture)
                
                imgView.sd_setImageWithURL(NSURL(string:media.url), completed: { (image, _, _, _) -> Void in
                    self.scrollViewMedias.addCustomView(imgView)
                    imgView.tag = photoIndex
                    
                    let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
                    let photo = PhotoShow(image: imgView.image, attributedCaptionTitle: title)
                    photo.index = photoIndex
                    
                    self.photos.append(photo)
                    
                    photoIndex++
                })
                                
            }
            
        }
    }
    
    func setupScrollView() {
        self.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
    }
    
    func imgViewTapped(sender:UITapGestureRecognizer) {
        
        let photosViewController = NYTPhotosViewController(photos: self.photos, initialPhoto:self.photos[sender.view!.tag])
        photosViewController.delegate = self
        presentViewController(photosViewController, animated: true, completion: nil)
        
    }
    
    //MARK: URStoryContributionTableViewCellDelegate
    
    func contributionTableViewCellDeleteButtonTapped(cell: URStoryContributionTableViewCell) {
        
        let alert = UIAlertController(title: nil, message: "Do you want remove this contribution?", preferredStyle: UIAlertControllerStyle.ActionSheet)

        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            let indexPath = self.tableView.indexPathForCell(cell)!
            self.listContribution.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            let totalContributions = Int(self.story.contributions) - 1
            self.lbContributions.text = "\(totalContributions) \("contributions".localized)"
            
            self.tableView.contentSize.height = CGFloat(totalContributions)
            URContributionManager.removeContribution(self.story.key, contributionKey: cell.contribution.key)
            
            self.view.layoutIfNeeded()
            
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //MARK: ContributionManagerDelegate
    
    func newContributionReceived(contribution: URContribution) {
        listContribution.append(contribution)
        self.lbContributions.text = "\(listContribution.count) contributions"        
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
//        print("Did dismiss Photo Viewer: \(photosViewController)")
    }
    
}

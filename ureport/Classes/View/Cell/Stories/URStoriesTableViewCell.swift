//
//  URStoriesTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 14/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

@objc protocol URStoriesTableViewCellDelegate {
    func openProfile(_ user:URUser)
    @objc optional func removeCell(_ cell:URStoriesTableViewCell)
}

class URStoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbAuthorName: UILabel!
    @IBOutlet weak var lbContributions: UILabel!
    @IBOutlet weak var lbMarkers: UILabel!
    @IBOutlet weak var lbLikes: UILabel!
    @IBOutlet weak var lbAttachments: UILabel!
    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var btContribute: UIButton!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var moderationView: UIView!
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var btDisapprove: UIButton!
    @IBOutlet weak var btPublish: UIButton!
    @IBOutlet weak var btReportContent: UIButton!

    @IBOutlet weak var lbContentTop: NSLayoutConstraint!
    @IBOutlet weak var contentViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lbTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var viewMarkerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewAttachmentHeight: NSLayoutConstraint!
    @IBOutlet weak var imgStoryHeight: NSLayoutConstraint!
    
    var story:URStory!
    let imgViewHistoryHeight:CGFloat = 188.0
    let lbDefaultTitleHeight:CGFloat = 45.0
    let viewMarkerDefautlHeight:CGFloat = 18.0
    let viewAttachmentDefaultHeight:CGFloat = 18.0
    
    var viewController:UIViewController?
    var delegate:URStoriesTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.btReportContent.isHidden = !(URSettings.getSettings().reviewMode!).boolValue
        
        self.bgView.layer.cornerRadius = 5
        btDisapprove.layer.cornerRadius = 5
        btPublish.layer.cornerRadius = 5
        btContribute.setTitle("story_item_contribute_to_story".localized, for: UIControlState())
        btDisapprove.setTitle("button_title_disapprove".localized, for: UIControlState())
        btPublish.setTitle("button_title_publish".localized, for: UIControlState())
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openModalProfile))
        tapGesture.numberOfTouchesRequired = 1
        self.imgUser.addGestureRecognizer(tapGesture)
    }
    
    override func prepareForReuse() {
        self.lbAuthorName.text = ""
        self.imgUser.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.none
        // Configure the view for the selected state
    }
    
    //MARK: Button Events
    
    @IBAction func btReportContentTapped(_ sender: AnyObject) {
        
        let reportContentAlertController: UIAlertController = UIAlertController(title: nil, message: "Report this content", preferredStyle: .actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel_dialog_button".localized, style: .cancel) { action -> Void in
            
        }
        
        let inappropriateContentAction: UIAlertAction = UIAlertAction(title: "Inappropriate content", style: .default) { action -> Void in
        }

        let spamAction: UIAlertAction = UIAlertAction(title: "Spam", style: .default) { action -> Void in
        }
        
        reportContentAlertController.addAction(spamAction)
        reportContentAlertController.addAction(inappropriateContentAction)
        reportContentAlertController.addAction(cancelAction)
        
        URNavigationManager.navigation.present(reportContentAlertController, animated: true, completion: nil)
        
    }
    
    @IBAction func btContributeTapped(_ sender: AnyObject) {
        if let _ = URUser.activeUser() {
            self.viewController!.navigationController?.pushViewController(URStoryContributionViewController(story: self.story), animated: true)
        }else {
            URLoginAlertController.show(self.viewController!)
        }
    }
    
    @IBAction func btDisapprovedTapped(_ sender: AnyObject) {
        URStoryManager.setStoryAsDisapproved(self.story) { (finished) -> Void in
            if let delegate = self.delegate {
                delegate.removeCell!(self)
            }
        }
    }
    
    @IBAction func btPublishTapped(_ sender: AnyObject) {
        URStoryManager.setStoryAsPublished(self.story) { (finished) -> Void in
            if let delegate = self.delegate {
                delegate.removeCell!(self)
            }
        }
    }
    
    //MARK: Class Methods
    
    func openModalProfile() {
        if let delegate = self.delegate {
            if story.user != URUser.activeUser()?.key {
                if let userObject = story.userObject {
                    delegate.openProfile(userObject)                    
                }
            }
        }
    }
    
    func setupCellWith(_ story:URStory,moderateUserMode:Bool){
        self.story = story
        
        if story.cover != nil && story.cover.url != nil {
            self.imgStoryHeight.constant = imgViewHistoryHeight
            self.lbContentTop.constant = 5
        }else {
            self.imgStoryHeight.constant = 0
            self.lbContentTop.constant = 0
        }
        
        self.contentView.layoutIfNeeded()
        self.contentView.setNeedsLayout()
        
//        if story.markers != nil && !story.markers.isEmpty {
//            self.markerView.hidden = false
//            self.viewMarkerHeight.constant = viewMarkerDefautlHeight
//        }else {
//            self.markerView.hidden = true
//            self.viewMarkerHeight.constant = 0
//        }
        
        if story.medias != nil && !story.medias.isEmpty {
            self.lbAttachments.text = String(format: "attachments".localized, arguments: [story.medias.count])
            self.attachmentView.isHidden = false
            self.viewAttachmentHeight.constant = viewAttachmentDefaultHeight
        }else {
            self.attachmentView.isHidden = true
            self.viewAttachmentHeight.constant = 0
        }
        
        URStoryManager.getStoryLikes(story.key, completion: { (likeCount) -> Void in
            story.like = likeCount as NSNumber!
            self.lbLikes.text = String(format: "likes".localized, arguments: [likeCount])
        })
        
        URContributionManager.getTotalContributions(story.key, completion: { (total:Int) -> Void in
            story.contributions = total as NSNumber!
            self.lbContributions.text = String(format: "stories_list_item_contributions".localized, arguments: [Int(story.contributions)])
        })
        
        URUserManager.getByKey(story.user, completion: { (user:URUser?, exists:Bool) -> Void in
            if user != nil && user!.nickname != nil {
                story.userObject = user
                
                self.lbAuthorName.text = "\(user!.nickname!)"
                
                if user!.picture != nil {
                    self.imgUser.contentMode = UIViewContentMode.scaleAspectFill
                    self.imgUser.sd_setImage(with: URL(string: user!.picture))
                }else{
                    self.imgUser.contentMode = UIViewContentMode.center
                    self.imgUser.image = UIImage(named: "ic_person")
                    
                    self.roundedView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
                }
            }
        })
        
        if story.cover != nil && story.cover.url != nil {
            
            if story.cover.type == URConstant.Media.VIDEOPHONE {
                self.imgStory.sd_setImage(with: URL(string: story.cover.thumbnail))
                
            } else if story.cover.type == URConstant.Media.PICTURE || story.cover.type == URConstant.Media.VIDEO {
                self.imgStory.sd_setImage(with: URL(string: story.cover.url))
            }
        }
        
        self.lbTitle.text = story.title!        
        
        self.lbMarkers.text = story.markers
        self.lbDescription.text = story.content
        
        self.moderationView.isHidden = !moderateUserMode
        
    }
}

//
//  URStoriesTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 14/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

@objc protocol URStoriesTableViewCellDelegate {
    func openProfile(user:URUser)
    optional func removeCell(cell:URStoriesTableViewCell)
}

class URStoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbAuthorName: UILabel!
    @IBOutlet weak var lbContributions: UILabel!
    @IBOutlet weak var lbMarkers: UILabel!
    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var btContribute: UIButton!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var moderationView: UIView!
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var btDisapprove: UIButton!
    @IBOutlet weak var btPublish: UIButton!

    @IBOutlet weak var lbContentTop: NSLayoutConstraint!
    @IBOutlet weak var contentViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lbTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var viewMarkerHeight: NSLayoutConstraint!
    @IBOutlet weak var imgStoryHeight: NSLayoutConstraint!
    
    var story:URStory!
    let imgViewHistoryHeight:CGFloat = 188.0
    let lbDefaultTitleHeight:CGFloat = 45.0
    let viewMarkerDefautlHeight:CGFloat = 25.0
    
    var viewController:UIViewController?
    var delegate:URStoriesTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bgView.layer.cornerRadius = 5
        self.viewSeparator.layer.cornerRadius = 7
        btDisapprove.layer.cornerRadius = 5
        btPublish.layer.cornerRadius = 5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "openModalProfile")
        tapGesture.numberOfTouchesRequired = 1
        self.imgUser.addGestureRecognizer(tapGesture)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.None
        // Configure the view for the selected state
    }
    
    //MARK: Button Events
    
    @IBAction func btContributeTapped(sender: AnyObject) {
        if let _ = URUser.activeUser() {
            self.viewController!.navigationController?.pushViewController(URStoryContributionViewController(story: self.story), animated: true)
        }else {
            URLoginAlertController.show(self.viewController!)
        }
    }
    
    @IBAction func btDisapprovedTapped(sender: AnyObject) {
        URStoryManager.setStoryAsDisapproved(self.story) { (finished) -> Void in
            if let delegate = self.delegate {
                delegate.removeCell!(self)
            }
        }
    }
    
    @IBAction func btPublishTapped(sender: AnyObject) {
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
    
    func setupCellWith(story:URStory,moderateUserMode:Bool){
        self.story = story
        
        if story.cover != nil && story.cover.url != nil {
            self.imgStoryHeight.constant = imgViewHistoryHeight
            self.lbContentTop.constant = 5
        }else {
            self.imgStoryHeight.constant = 0
            self.lbContentTop.constant = 0
        }
        
        if story.markers != nil && !story.markers.isEmpty {
            self.markerView.hidden = false
            self.viewMarkerHeight.constant = viewMarkerDefautlHeight
        }else {
            self.markerView.hidden = true
            self.viewMarkerHeight.constant = 0
        }

        self.contentView.layoutIfNeeded()
        
        self.lbTitle.text = story.title!
        self.lbContributions.text = "\(story.contributions!) \("contributions".localized)"
        if let userObject = story.userObject {
            
            self.lbAuthorName.text = "\(userObject.nickname!)"
            
            if userObject.picture != nil {
                self.imgUser.sd_setImageWithURL(NSURL(string: userObject.picture))
            }else{
                self.imgUser.contentMode = UIViewContentMode.Center
                self.imgUser.image = UIImage(named: "ic_person")
                
                self.roundedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            }
        }
        
        if story.cover != nil && story.cover.url != nil {
            self.imgStory.sd_setImageWithURL(NSURL(string: story.cover.url))
        }
        self.lbMarkers.text = story.markers
        self.lbDescription.text = story.content
        
        self.moderationView.hidden = !moderateUserMode
        
    }
}

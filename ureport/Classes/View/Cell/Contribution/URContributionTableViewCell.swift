//
//  URStoryContributionTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 16/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URContributionTableViewCellDelegate {
    func contributionTableViewCellDeleteButtonTapped(cell:URContributionTableViewCell)
}

class URContributionTableViewCell: UITableViewCell {

    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lbContributionText: UILabel!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var btDelete: UIButton!
    
    var delegate:URContributionTableViewCellDelegate?
    var contribution:URContribution!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.None
        // Configure the view for the selected state
    }
    
    //MARK: Button Events
    
    @IBAction func btDeleteTapped(sender:AnyObject) {
        
        if let delegate = self.delegate {
            delegate.contributionTableViewCellDeleteButtonTapped(self)
        }
        
    }
    
    //MARK: Class Methods
    
    func setupCellWith(contribution:URContribution, indexPath:NSIndexPath) {
        self.contribution = contribution
        
        self.lbContributionText.text = "\(contribution.content)\n"
        self.lbUserName.text = contribution.author.nickname
        self.lbDate.text = "\(NSDate().offsetFrom(NSDate(timeIntervalSince1970: NSNumber(double: contribution.createdDate.doubleValue/1000) as NSTimeInterval))) ago"
        
        if let picture = contribution.author.picture {
            self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            self.imgUser.sd_setImageWithURL(NSURL(string: picture))
        }else{
            self.roundedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            self.imgUser.contentMode = UIViewContentMode.Center
            self.imgUser.image = UIImage(named: "ic_person")
        }                
        
        if let user = URUser.activeUser() {
            
            if user.masterModerator != nil || user.moderator != nil {
                self.btDelete.hidden = false
            }else {
                self.btDelete.hidden = true
            }
            
        }
        
    }
    
}

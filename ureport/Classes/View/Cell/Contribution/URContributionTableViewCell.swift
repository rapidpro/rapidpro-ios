//
//  URStoryContributionTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 16/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URContributionTableViewCellDelegate {
    func contributionTableViewCellDeleteButtonTapped(_ cell:URContributionTableViewCell)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.none
        // Configure the view for the selected state
    }
    
    //MARK: Button Events
    
    @IBAction func btDeleteTapped(_ sender:AnyObject) {
        
        if let delegate = self.delegate {
            delegate.contributionTableViewCellDeleteButtonTapped(self)
        }
        
    }
    
    //MARK: Class Methods
    
    func setupCellWith(_ contribution:URContribution, indexPath:IndexPath) {
        self.contribution = contribution
        
        self.lbContributionText.text = "\(contribution.content!)\n"
        self.lbUserName.text = contribution.author.nickname
        self.lbDate.text = Date.localizedOffsetFrom(Date(timeIntervalSince1970: NSNumber(value: contribution.createdDate.doubleValue/1000 as Double) as TimeInterval))
        
        if let picture = contribution.author.picture {
            self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(1)
            self.imgUser.contentMode = UIViewContentMode.scaleAspectFill
            self.imgUser.sd_setImage(with: URL(string: picture))
        }else{
            self.roundedView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            self.imgUser.contentMode = UIViewContentMode.center
            self.imgUser.image = UIImage(named: "ic_person")
        }                
        
        if let user = URUser.activeUser() {
            
            if user.masterModerator != nil || user.moderator != nil {
                self.btDelete.isHidden = false
            }else {
                self.btDelete.isHidden = true
            }
            
        }
        
    }
    
}

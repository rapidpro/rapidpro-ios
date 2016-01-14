//
//  URInviteTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URInviteTableViewCellDelegate {
    func inviteButtonDidTapped(cell:URInviteTableViewCell)
}

class URInviteTableViewCell: UITableViewCell {

    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var imgContact: UIImageView!
    @IBOutlet weak var lbContactName: UILabel!
    @IBOutlet weak var lbPhoneNumber: UILabel!
    @IBOutlet weak var btInvite: UIButton!
    
    var delegate:URInviteTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btInvite.layer.cornerRadius = 3
        self.btInvite.setTitle("chat_contact_invite_button".localized, forState: UIControlState.Normal)
        super.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.imgContact.contentMode = UIViewContentMode.Center
        self.imgContact.image = UIImage(named: "ic_person")        
        self.roundedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Button Events
    
    @IBAction func btInviteTapped(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.inviteButtonDidTapped(self)
        }
    }
    
    
}

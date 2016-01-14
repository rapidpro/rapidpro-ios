//
//  URWriteStoryTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 03/12/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URWriteStoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var btWrite: ISRoundedButton!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.bgView.layer.cornerRadius = 5
        self.separatorView.layer.cornerRadius = 5
    }    
    
    //MARK: Class Methods
    
    func setupLayout() {
        if let user = URUser.activeUser() {
            self.lbMsg.text = String(format: "list_stories_header_title".localized, arguments: [user.nickname])
            
            if user.picture != nil && user.picture.characters.count > 0 {
                self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
                self.imgProfile.contentMode = UIViewContentMode.ScaleAspectFit
                self.imgProfile.sd_setImageWithURL(NSURL(string: user.picture))
            }else{
                self.roundedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                self.imgProfile.contentMode = UIViewContentMode.Center
                self.imgProfile.image = UIImage(named: "ic_person")
            }
            
        }else{
            self.lbMsg.text = String(format: "list_stories_header_title".localized, arguments: [""])
        }
    }
    
}

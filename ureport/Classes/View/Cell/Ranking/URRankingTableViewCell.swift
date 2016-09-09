//
//  URRankingTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 28/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URRankingTableViewCell: UITableViewCell {

    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbPoints: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    
    var user:URUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    //MARK: Class Methods
    
    func setupCellWith(user:URUser) {
        self.user = user
        
        self.lbUserName.text = user.nickname
        self.lbPoints.text = "\(user.points)"

        if user.picture != nil && !(user.picture.isEmpty) {
            self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            self.imageProfile.contentMode = UIViewContentMode.ScaleAspectFill
            self.imageProfile.sd_setImageWithURL(NSURL(string: user.picture))
        }else{
            self.roundedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            self.imageProfile.contentMode = UIViewContentMode.Center
            self.imageProfile.image = UIImage(named: "ic_person")
        }
        
    }
    
}

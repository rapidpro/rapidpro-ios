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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    //MARK: Class Methods
    
    func setupCellWith(_ user:URUser) {
        self.user = user
        
        self.lbUserName.text = user.nickname
        self.lbPoints.text = "\(user.points)"

        if user.picture != nil && !((user.picture?.isEmpty)!) {
            self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(1)
            self.imageProfile.contentMode = UIViewContentMode.scaleAspectFill
            self.imageProfile.sd_setImage(with: URL(string: user.picture!))
        }else{
            self.roundedView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            self.imageProfile.contentMode = UIViewContentMode.center
            self.imageProfile.image = UIImage(named: "ic_person")
        }
        
    }
    
}

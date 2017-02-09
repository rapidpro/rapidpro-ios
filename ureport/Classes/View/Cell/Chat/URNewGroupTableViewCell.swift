//
//  URNewGroupTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 17/08/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

protocol URNewGroupTableViewCellDelegate {
    func createNewGroupCellDidTap(_ cell:URNewGroupTableViewCell)
}

class URNewGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var imgViewGroup: UIImageView!
    @IBOutlet weak var roundedView: ISRoundedView!
    
    var delegate:URNewGroupTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lbName.text = "new_group".localized
        self.imgViewGroup.image = UIImage(named: "icon_group_add_grey")
        self.roundedView.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(createNewGroup))
        tapGesture.numberOfTapsRequired = 1
        self.contentView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Class Methods
    
    func createNewGroup() {
        delegate?.createNewGroupCellDidTap(self)
    }
    
    //MARK: Component Events
    
}

//
//  URSettingsTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 19/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URSettingsTableViewCellDelegate {
    func switchEnableDidTapped(_ cell:URSettingsTableViewCell)
}

class URSettingsTableViewCell: UITableViewCell {
    
    var index:Int!
    var delegate:URSettingsTableViewCellDelegate?
    
    @IBOutlet weak var lbSettingName: UILabel!
    @IBOutlet weak var switchEnable: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    //MARK: Button Events
    
    
    @IBAction func switchEnableTapped(_ sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.switchEnableDidTapped(self)
        }
    }
    
}

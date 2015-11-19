//
//  URSettingsTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 19/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URSettingsTableViewCellDelegate {
    func switchEnableDidTapped(cell:URSettingsTableViewCell)
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    //MARK: Button Events
    
    
    @IBAction func switchEnableTapped(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.switchEnableDidTapped(self)
        }
    }
    
}

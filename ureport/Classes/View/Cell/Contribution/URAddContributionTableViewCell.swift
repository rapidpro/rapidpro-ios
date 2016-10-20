//
//  URAddContributionTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 10/08/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

protocol URAddContributionTableViewCellDelegate {
    func newContributionAdded(_ cell:URAddContributionTableViewCell)
}

class URAddContributionTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var txtContribution:UITextField!
    
    var delegate:URAddContributionTableViewCellDelegate?
    var parentViewController:UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtContribution.placeholder = "story_item_contribute_to_story".localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Textfield Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let _ = URUser.activeUser() {
            return true
        }else {
            URLoginAlertController.show(parentViewController)
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.text!.isEmpty{
            if let delegate = self.delegate {
                delegate.newContributionAdded(self)
                textField.text = ""
                textField.resignFirstResponder()
            }
        }
        
        return true
    }
    
}

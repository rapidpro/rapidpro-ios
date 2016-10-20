//
//  URAddMarkerTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 14/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol AddMarkerTableViewCellDelegate {
    func newMarkerAdded(_ marker:URMarker)
}

class URAddMarkerTableViewCell: UITableViewCell, UITextFieldDelegate {

    var delegate:AddMarkerTableViewCellDelegate?
    
    @IBOutlet weak var txtMarkerName: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtMarkerName.placeholder = "create_story_add_marker_title".localized
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.text!.isEmpty{
            if let delegate = self.delegate {
                delegate.newMarkerAdded(URMarker(name: textField.text!))
                textField.text = ""
                textField.resignFirstResponder()
            }
        }
        
        return true
    }
    
}

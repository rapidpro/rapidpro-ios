//
//  URAddMarkerTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 14/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol AddMarkerTableViewCellDelegate {
    func newMarkerAdded(marker:URMarker)
}

class URAddMarkerTableViewCell: UITableViewCell, UITextFieldDelegate {

    var delegate:AddMarkerTableViewCellDelegate?
    
    @IBOutlet weak var txtMarkerName: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Textfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
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

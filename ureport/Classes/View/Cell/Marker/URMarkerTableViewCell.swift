//
//  URMarkerTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 14/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol MarkerTableViewCellDelegate {
    func markerHasTapped(cell:URMarkerTableViewCell)
}

class URMarkerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btCheck: UIButton!
    @IBOutlet weak var lbName: UILabel!
    
    var marker:URMarker!
    var delegate:MarkerTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    //MARK: Class Methods
    
    func setupCellWith(marker:URMarker) {
        self.marker = marker
        lbName.text = marker.name
    }
    
    func setBtCheckSelected(selected:Bool) {
        if selected == true {
            btCheck.selected = true
            btCheck.setBackgroundImage(UIImage(named: "radio_button_active"), forState: UIControlState.Selected)
        }else {
            btCheck.selected = false
            btCheck.setBackgroundImage(UIImage(named: "radio_button_Inactive"), forState: UIControlState.Normal)
        }
    }
    
    //MARK: Button Events
    
    @IBAction func btCheckTapped(sender: AnyObject) {
        
        if let delegate = self.delegate {
            delegate.markerHasTapped(self)
        }
        
        if btCheck.selected {
            setBtCheckSelected(false)
        }else{
            setBtCheckSelected(true)            
        }
    }
    
}

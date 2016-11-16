//
//  URMarkerTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 14/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol MarkerTableViewCellDelegate {
    func markerHasTapped(_ cell:URMarkerTableViewCell)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    //MARK: Class Methods
    
    func setupCellWith(_ marker:URMarker) {
        self.marker = marker
        lbName.text = marker.name
    }
    
    func setBtCheckSelected(_ selected:Bool) {
        if selected == true {
            btCheck.isSelected = true
            btCheck.setBackgroundImage(UIImage(named: "radio_button_active"), for: UIControlState.selected)
        }else {
            btCheck.isSelected = false
            btCheck.setBackgroundImage(UIImage(named: "radio_button_Inactive"), for: UIControlState())
        }
    }
    
    //MARK: Button Events
    
    @IBAction func btCheckTapped(_ sender: AnyObject) {
        
        if let delegate = self.delegate {
            delegate.markerHasTapped(self)
        }
        
        if btCheck.isSelected {
            setBtCheckSelected(false)
        }else{
            setBtCheckSelected(true)            
        }
    }
    
}

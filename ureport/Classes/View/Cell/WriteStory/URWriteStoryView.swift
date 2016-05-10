//
//  URWriteStoryTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 03/12/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URWriteStoryViewDelegate {
    func writeStoryDidTap(cell:URWriteStoryView)
}

class URWriteStoryView: UIView {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var btWrite: ISRoundedButton!
    @IBOutlet weak var separatorView: UIView!
    
    var delegate:URWriteStoryViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(callDelegate))
        self.addGestureRecognizer(gesture)
    }
    
    //MARK: Class Methods
    
    func setupLayout() {
        self.separatorView.layer.cornerRadius = 5
        
        if let user = URUser.activeUser() {
            self.lbMsg.text = String(format: "list_stories_header_title".localized, arguments: [user.nickname])
            
            if user.picture != nil && user.picture.characters.count > 0 {
                self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
                self.imgProfile.contentMode = UIViewContentMode.ScaleAspectFit
                self.imgProfile.sd_setImageWithURL(NSURL(string: user.picture))
            }else{
                self.roundedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                self.imgProfile.contentMode = UIViewContentMode.Center
                self.imgProfile.image = UIImage(named: "ic_person")
            }
            
        }else{
            self.lbMsg.text = String(format: "list_stories_header_title".localized, arguments: [""])
        }
    }
    
    //MARK: ButtonEvents
    
    func callDelegate() {
        if let delegate = self.delegate {
            delegate.writeStoryDidTap(self)
        }
    }

}

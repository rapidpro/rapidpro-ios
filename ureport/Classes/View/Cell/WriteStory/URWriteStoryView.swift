//
//  URWriteStoryTableViewCell.swift
//  ureport
//
//  Created by Daniel Amaral on 03/12/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URWriteStoryViewDelegate {
    func writeStoryDidTap(_ cell:URWriteStoryView)
}

class URWriteStoryView: UIView {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var lbMsg: UILabel!
    
    var delegate:URWriteStoryViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
        self.bgView.layer.cornerRadius = 5
        let gesture = UITapGestureRecognizer(target: self, action: #selector(callDelegate))
        self.addGestureRecognizer(gesture)
    }
    
    //MARK: Class Methods
    
    func setupLayout() {
        
        if let user = URUser.activeUser() {
            self.lbMsg.text = String(format: "list_stories_header_title".localized, arguments: [user.nickname!])
            
            if user.picture != nil && user.picture!.characters.count > 0 {
                self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(1)
                self.imgProfile.contentMode = UIViewContentMode.scaleAspectFill
                self.imgProfile.sd_setImage(with: URL(string: user.picture!))
            }else{
                setupUserImageAsDefault()
            }
            
        }else{
            self.lbMsg.text = String(format: "list_stories_header_title".localized, arguments: [""])
            setupUserImageAsDefault()
        }
    }
    
    func setupUserImageAsDefault() {
        self.roundedView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        self.imgProfile.contentMode = UIViewContentMode.center
        self.imgProfile.image = UIImage(named: "ic_person")
    }
    
    //MARK: ButtonEvents
    
    func callDelegate() {
        if let delegate = self.delegate {
            delegate.writeStoryDidTap(self)
        }
    }

}

//
//  URFileView.swift
//  ureport
//
//  Created by Daniel Amaral on 17/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URMediaFileView: UIView {
    
    @IBOutlet weak var lbFileName:UILabel!
    @IBOutlet weak var lbSubtitle:UILabel!
    @IBOutlet weak var btOpen:UIButton!
    
    var media:URMedia!
    
    //MARK: Class Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
    }
    
    func setupWithMedia(_ media:URMedia) {
        
        self.media = media
        
        if let metadaData = media.metadata {
            let filename = metadaData["filename"] as! String
            self.lbFileName.text = filename
            self.lbSubtitle.text = URL(fileURLWithPath: media.url).pathExtension
        }
    }
    
    //MARK: Button Events
    
    @IBAction func btOpenTapped(_ button:UIButton) {
        if let checkURL = URL(string: media.url) {
            if UIApplication.shared.openURL(checkURL) {
                print("url successfully opened")
            }
        } else {
            print("invalid url")
        }
    }
    
}

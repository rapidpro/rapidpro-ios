//
//  UIImageViewExtension.swift
//  ureport
//
//  Created by Yves Bastos on 22/12/2017.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    
    func setImage(url: String?) {
        if let pictureUrl = url {
            self.contentMode = .scaleAspectFill
            self.sd_setImage(with: URL(string: pictureUrl), placeholderImage: #imageLiteral(resourceName: "ic_person"), options: [], completed: { (image, error, cache, url) in
                if error != nil {
                   self.setPlaceholder()
                }
            })
        } else {
            setPlaceholder()
        }
    }
    
    func setPlaceholder() {
        self.contentMode = .center
        self.image = #imageLiteral(resourceName: "ic_person")
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
    }
}

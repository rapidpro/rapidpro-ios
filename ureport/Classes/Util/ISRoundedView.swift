//
//  ISRoundedView.swift
//  ureport
//
//  Created by Daniel Amaral on 14/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class ISRoundedView: UIView {

    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }

}

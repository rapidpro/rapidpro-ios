//
//  ISCircleButton.swift
//  ureport
//
//  Created by Daniel Amaral on 21/01/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class ISCircleButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = self.frame.width/2
    }

}

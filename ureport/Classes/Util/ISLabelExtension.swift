//
//  ISLabelExtension.swift
//  ureport
//
//  Created by Daniel Amaral on 19/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

extension UILabel {
    func setSizeFont (_ sizeFont: CGFloat) {
        self.font =  UIFont(name: self.font.fontName, size: sizeFont)!
        self.sizeToFit()
    }
    
    func lineCount() -> Int {
        let constrain: CGSize = CGSize(width: self.bounds.size.width, height: CGFloat(FLT_MAX))
        let size: CGRect = self.text!.boundingRect(with: constrain, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: self.font], context: nil)
        return Int(ceil(size.height / self.font.lineHeight))
    }
}

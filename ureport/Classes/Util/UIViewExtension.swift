//
//  UIViewExtension.swift
//  ureport
//
//  Created by Yves Bastos on 06/12/2017.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import Foundation

extension UIView {
    func snapshot(size: CGSize) -> UIImage? {
        var image: UIImage?
        
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: size)
            image = renderer.image { ctx in
                self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            }
        } else {
            image = self.toImage()
        }
        return image
    }
    
}

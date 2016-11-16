//
//  ISViewExtension.swift
//  TimeDePrimeira
//
//  Created by Daniel Amaral on 03/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

extension UIView {
   
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func findTextFieldEmptyInView(_ input: UIView) -> UITextField? {
        if input.isKind(of: UITextField.self) {
            let textField:UITextField! = input as! UITextField
            if textField.text!.isEmpty {
                
                if (textField.placeholder != nil) {
                    return textField
                }else{
                    print("textfield doesn't have placeHolder")
                }
                
            }
        }

        for view in input.subviews {
            if let foundView = self.findTextFieldEmptyInView(view ) {
                return foundView
            }
        }
        return nil
    }
    
}

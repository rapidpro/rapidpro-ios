//
//  UITextField+Keyboard.swift
//  ureport
//
//  Created by Daniel Amaral on 11/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit


extension UIViewController: UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: Delegate Methods
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        setupAccessoryView(textField)
        return true
        
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupAccessoryView(textView)
        return true
    }
    
    //MARK: Methods
    
    public func closeKeyBoard() {
        self.view.endEditing(true)
    }
    
    fileprivate func setupAccessoryView(_ component:AnyObject) {
        let keyboardToolBar:UIToolbar! = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        keyboardToolBar!.barStyle = UIBarStyle.default
        
        let arrayButtonItem:[UIBarButtonItem]! = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
                                                  UIBarButtonItem(title: NSLocalizedString("points_earning_close".localized, comment: ""), style: UIBarButtonItemStyle.done, target: self, action: #selector(closeKeyBoard))]
        
        keyboardToolBar?.setItems(arrayButtonItem, animated: true)
        
        var textView:UITextView?
        var textField:UITextField?
        
        if component is UITextField {
            textField = component as? UITextField
            textField?.inputAccessoryView = keyboardToolBar
        }else {
            textView = component as? UITextView
            textView?.inputAccessoryView = keyboardToolBar
        }
        
    }
    
}

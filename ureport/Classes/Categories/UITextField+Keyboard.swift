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
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        setupAccessoryView(textField)
        return true
        
    }
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        setupAccessoryView(textView)
        return true
    }
    
    //MARK: Methods
    
    public func closeKeyBoard() {
        self.view.endEditing(true)
    }
    
    private func setupAccessoryView(component:AnyObject) {
        let keyboardToolBar:UIToolbar! = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        keyboardToolBar!.barStyle = UIBarStyle.Default
        
        let arrayButtonItem:[UIBarButtonItem]! = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: NSLocalizedString("close", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: "closeKeyBoard")]
        
        keyboardToolBar?.setItems(arrayButtonItem, animated: true)
        
        var textView:UITextView?
        var textField:UITextField?
        
        if component.isKindOfClass(UITextField){
            textField = component as? UITextField
            textField?.inputAccessoryView = keyboardToolBar
        }else {
            textView = component as? UITextView
            textView?.inputAccessoryView = keyboardToolBar
        }
        
    }
    
}
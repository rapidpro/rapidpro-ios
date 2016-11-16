//
//  UROpenFieldResponseView.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 19/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol UROpenFieldResponseDelegate {
    func onOpenFieldResponseChanged(_ flowRule: URFlowRule, text:String)
}

class UROpenFieldResponseView: URResponseView {

    var delegate: UROpenFieldResponseDelegate?
    @IBOutlet weak var tfResponse: UITextField!
    
    //MARK: Superclass methods
    
    override func unselectResponse() {
        tfResponse.text = ""
    }
    
    //MARK: Actions
    @IBAction func responseChanged(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.onOpenFieldResponseChanged(flowRule, text: tfResponse.text!)
        }
    }
}

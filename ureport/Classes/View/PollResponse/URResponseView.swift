//
//  URResponseView.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 20/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URResponseView: UIView {
    
    var flowDefinition:URFlowDefinition!
    var flowRule:URFlowRule!
    var selectedLanguage:String? {
        didSet {
            selectLanguage(selectedLanguage)
        }
    }
    
    func setFlowRule(flowDefinition:URFlowDefinition, flowRule:URFlowRule) {
        self.flowDefinition = flowDefinition
        self.flowRule = flowRule
    }
    
    func unselectResponse() {}
    
    func selectLanguage(language:String?){}

}

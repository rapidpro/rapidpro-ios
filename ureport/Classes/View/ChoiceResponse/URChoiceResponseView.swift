//
//  URChoiceResponseView.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 19/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URChoiceResponseDelegate {
    func onChoiceSelected(flowRule:URFlowRule)
}

class URChoiceResponseView: URResponseView {
    
    var delegate:URChoiceResponseDelegate?

    @IBOutlet weak var lbResponse: UILabel!
    @IBOutlet weak var btCheck: UIButton!
    
    //MARK: Superclass methods
    
    override func setFlowRule(flowDefinition:URFlowDefinition, flowRule:URFlowRule) {
        super.setFlowRule(flowDefinition, flowRule: flowRule)
        lbResponse.text = flowRule.ruleCategory[getLanguage()]
    }
    
    override func unselectResponse() {
        btCheck.selected = false
        btCheck.setBackgroundImage(UIImage(named: "radio_button_Inactive"), forState: UIControlState.Normal)
    }
    
    override func selectLanguage(language: String?) {
        lbResponse.text = flowRule.ruleCategory[getLanguage()]
    }
    
    //MARK: Actions
    
    @IBAction func toggleCheckButton(sender:AnyObject?) {
        if !btCheck.selected {
            btCheck.selected = true
            btCheck.setBackgroundImage(UIImage(named: "radio_button_active"), forState: UIControlState.Selected)
            
            if delegate != nil {
                delegate?.onChoiceSelected(flowRule)
            }
        } else {
            unselectResponse()
        }
    }

    //MARK: Class methods
    
    func getLanguage() -> String {
        return selectedLanguage != nil && flowRule.ruleCategory.keys.contains(selectedLanguage!) ? selectedLanguage! : flowDefinition.baseLanguage!
    }
}

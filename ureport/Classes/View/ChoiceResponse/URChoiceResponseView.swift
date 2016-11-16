//
//  URChoiceResponseView.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 19/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URChoiceResponseDelegate {
    func onChoiceSelected(_ flowRule:URFlowRule)
}

class URChoiceResponseView: URResponseView {
    
    var delegate:URChoiceResponseDelegate?

    @IBOutlet weak var lbResponse: UILabel!
    @IBOutlet weak var btCheck: UIButton!
    
    //MARK: Superclass methods
    
    override func setFlowRule(_ flowDefinition:URFlowDefinition, flowRule:URFlowRule) {
        super.setFlowRule(flowDefinition, flowRule: flowRule)
        lbResponse.text = flowRule.ruleCategory[getLanguage()]
    }
    
    override func unselectResponse() {
        btCheck.isSelected = false
        btCheck.setBackgroundImage(UIImage(named: "radio_button_Inactive"), for: UIControlState())
    }
    
    override func selectLanguage(_ language: String?) {
        lbResponse.text = flowRule.ruleCategory[getLanguage()]
    }
    
    //MARK: Actions
    
    @IBAction func toggleCheckButton(_ sender:AnyObject?) {
        if !btCheck.isSelected {
            btCheck.isSelected = true
            btCheck.setBackgroundImage(UIImage(named: "radio_button_active"), for: UIControlState.selected)
            
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

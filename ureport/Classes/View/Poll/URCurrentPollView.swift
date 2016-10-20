//
//  URCurrentPollView.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 18/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public protocol URCurrentPollViewDelegate {
    func onBoundsChanged()
}

class URCurrentPollView: UITableViewCell, URChoiceResponseDelegate, UROpenFieldResponseDelegate {
    
    @IBOutlet weak var lbCurrentPoll: UILabel!
    @IBOutlet weak var lbFlowName: UILabel!
    @IBOutlet weak var btNext: UIButton!
    @IBOutlet weak var viewResponses: UIView!
    @IBOutlet weak var tvQuestion: UITextView!
    @IBOutlet weak var constraintQuestionHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintResponseHeight: NSLayoutConstraint!
    @IBOutlet weak var btSwitchLanguage: UIButton!
    
    var actionSheetLanguage: UIAlertController!
    var delegate: URCurrentPollViewDelegate?
    
    let responseHeight = 47
    let flowTypeManager = URFlowTypeManager()
    
    var languages = Set<String>()
    var selectedLanguage:String?
    
    var viewController:UIViewController!
    var contact:URContact!
    var flowDefinition:URFlowDefinition!
    var flowRuleset:URFlowRuleset?
    var flowActionSet:URFlowActionSet?
    
    var flowRule:URFlowRule?
    var response:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.btNext.setTitle("next".localized, for: UIControlState())
        self.lbCurrentPoll.text = "polls_current".localized
        self.btSwitchLanguage.setTitle("switch_language".localized, for: UIControlState())
        
        btNext.layer.cornerRadius = 5
        
        let preferredLanguage = URSettings.getSettings().preferredLanguage
        selectedLanguage = preferredLanguage != nil ? String(preferredLanguage!) : nil
    }
    
    //MARK: Responses delegates
    
    func onChoiceSelected(_ flowRule: URFlowRule) {
        self.flowRule = flowRule
        self.response = self.getResponseFromRule(flowRule)
        unselectResponses()
    }
    
    func onOpenFieldResponseChanged(_ flowRule: URFlowRule, text: String) {
        self.flowRule = flowRule
        self.response = text
        unselectResponses()
    }
    
    //MARK: Actions
    
    @IBAction func switchLanguage(_ sender: AnyObject) {
        viewController.present(actionSheetLanguage, animated: true, completion: nil)
    }
    
    //MARK: Class Methods
    
    func unselectResponses() {
        let viewResponsesChildren = viewResponses.subviews as! [URResponseView]
        for responseView in viewResponsesChildren {
            if(responseView.flowRule.uuid != self.flowRule!.uuid) {
                responseView.unselectResponse()
            }
        }
    }
    
    func getCurrentPollHeight() -> CGFloat {
        return constraintQuestionHeight.constant + constraintResponseHeight.constant + 127 + btSwitchLanguage.frame.size.height
    }
    
    func getResponse() -> URRulesetResponse? {
        if !(self.flowRule == nil && self.response == nil) {
            return URRulesetResponse(rule: self.flowRule!, response: self.response!)
        }else {
            return nil
        }
    }
    
    fileprivate func getResponseFromRule(_ rule:URFlowRule) -> String {
        var response = rule.test?.base
        if response == nil && rule.test?.test != nil
            && rule.test?.test.values.count > 0 {
            response = rule.test?.test[(flowDefinition?.baseLanguage)!]
        }
        return response!
    }
    
    func setupData(_ flowDefinition: URFlowDefinition, flowActionSet: URFlowActionSet, flowRuleset:URFlowRuleset?, contact:URContact) {
        self.flowRule = nil
        self.response = nil
        
        self.contact = contact
        self.flowDefinition = flowDefinition
        self.flowRuleset = flowRuleset
        self.flowActionSet = flowActionSet
        self.lbFlowName.text = flowDefinition.metadata?.name
        
        self.btNext.isHidden = false
        
        setupNextStep()
    }
    
    func setupDataWithNoAnswer(_ flowDefinition: URFlowDefinition?, flowActionSet: URFlowActionSet?, flowRuleset:URFlowRuleset?, contact:URContact?) {
        self.flowRule = nil
        self.response = nil
        
        self.contact = contact
        self.flowDefinition = flowDefinition
        self.flowRuleset = flowRuleset
        self.flowActionSet = flowActionSet
        self.lbFlowName.text = flowDefinition?.metadata?.name
        
        removeAnswersViewOfLastQuestion()
        setupLanguages()
        setupQuestionTitle()
        
        self.btNext.isHidden = true
        self.constraintResponseHeight.constant = CGFloat(viewResponses.subviews.count * responseHeight)
    }
    
    func setupNextStep() {
        setupLanguages()
        setupQuestionTitle()
        setupQuestionAnswers()
    }
    
    func getChoiceResponse(_ flowRule:URFlowRule, frame:CGRect) -> URResponseView {
        let choiceResponseView = Bundle.main.loadNibNamed("URChoiceResponseView", owner: 0, options: nil)?[0] as! URChoiceResponseView
        choiceResponseView.frame = frame
        choiceResponseView.delegate = self
        return choiceResponseView
    }
    
    func getOpenFieldResponse(_ flowRule:URFlowRule, frame:CGRect) -> URResponseView {
        let openFieldResponseView = Bundle.main.loadNibNamed("UROpenFieldResponseView", owner: 0, options: nil)?[0] as! UROpenFieldResponseView
        openFieldResponseView.frame = frame
        openFieldResponseView.delegate = self
        return openFieldResponseView
    }
    
    fileprivate func setupLanguages() {
        for action in flowActionSet!.actions! {
            for key in action.message.keys {
                languages.insert(key)
            }
        }
        
        btSwitchLanguage.isHidden = languages.count <= 1
        
        actionSheetLanguage = UIAlertController(title: nil, message: "switch_language".localized, preferredStyle: .actionSheet)
        
        for language in languages.sorted() {
            let languageDescription = URCountry.getLanguageDescription(language, type: URCountryCodeType.iso3) ?? language
            
            let switchLanguageAction = UIAlertAction(title: languageDescription, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                let settings = URSettings()
                settings.preferredLanguage = language as NSString?
                URSettings.saveSettingsLocaly(settings)
                
                self.selectedLanguage = language
                self.setupQuestionTitle()
                for responseView in self.viewResponses.subviews as! [URResponseView] {
                    responseView.selectedLanguage = language
                }
                
                if self.delegate != nil {
                    self.delegate?.onBoundsChanged()
                }
            })
            actionSheetLanguage.addAction(switchLanguageAction)
        }
        
        let cancelAction = UIAlertAction(title: "cancel_dialog_button".localized, style: .cancel, handler: nil)
        actionSheetLanguage.addAction(cancelAction)
    }
    
    fileprivate func setupQuestionTitle() {
        self.tvQuestion.text = URFlowManager.translateFields(contact, message: (flowActionSet?.actions?[0].message == nil || flowActionSet?.actions?[0].message.count == 0 ? "answer_poll_greeting_message".localized : flowActionSet?.actions?[0].message[getSelectedLanguage()])!)
        let sizeThatFitsTextView = tvQuestion.sizeThatFits(CGSize(width: tvQuestion.frame.size.width, height: CGFloat.greatestFiniteMagnitude));
        constraintQuestionHeight.constant = sizeThatFitsTextView.height;
    }
    
    fileprivate func removeAnswersViewOfLastQuestion() {
        let array = self.viewResponses.subviews as [UIView]
        for view in array {
            view.removeFromSuperview()
        }
    }
    
    fileprivate func setupQuestionAnswers() {
        
        removeAnswersViewOfLastQuestion()
        
        guard let flowRuleset = flowRuleset else {
            self.constraintResponseHeight.constant = 0
            return
        }
        
        for flowRule in (flowRuleset.rules)! {
            if !URFlowManager.hasRecursiveDestination(flowDefinition, ruleSet: flowRuleset, rule: flowRule) {
                
                let frame = CGRect(x: 0, y: CGFloat(viewResponses.subviews.count * responseHeight), width: viewResponses.frame.width, height: CGFloat(responseHeight))
                var responseView:URResponseView?
                
                let typeValidation = flowTypeManager.getTypeValidationForRule(flowRule)
                switch typeValidation.type! {
                case URFlowType.openField:
                    responseView = getOpenFieldResponse(flowRule, frame: frame)
                    break
                case URFlowType.choice:
                    responseView = getChoiceResponse(flowRule, frame: frame)
                    break
                case URFlowType.number:
                    responseView = getOpenFieldResponse(flowRule, frame: frame)
                    break
                default: break
                }
                
                responseView?.setFlowRule(flowDefinition, flowRule: flowRule)
                responseView?.selectedLanguage = self.selectedLanguage
                self.viewResponses.addSubview(responseView!)
                self.constraintResponseHeight.constant = CGFloat(viewResponses.subviews.count * responseHeight)
            }
        }
    }
    
    fileprivate func getSelectedLanguage() -> String {
        return (selectedLanguage != nil && (flowActionSet?.actions?[0].message.keys.contains(selectedLanguage!))! ? selectedLanguage : flowDefinition.baseLanguage)!
    }
}

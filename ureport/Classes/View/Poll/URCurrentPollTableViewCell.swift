//
//  URCurrentPollView.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 18/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URCurrentPollTableViewCell: UITableViewCell {

    @IBOutlet weak var lbFlowName: UILabel!
    @IBOutlet weak var btNext: UIButton!
    @IBOutlet weak var viewResponses: UIView!
    @IBOutlet weak var tvQuestion: UITextView!
    @IBOutlet weak var constraintQuestionHeight: NSLayoutConstraint!
    
    let viewChoiceHeight = 57
    
    var flowDefinition:URFlowDefinition!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btNext.layer.cornerRadius = 5
    }
    
    //MARK: Class Methods
    
    func setupCellWithData(flowDefinition: URFlowDefinition) {
        self.flowDefinition = flowDefinition;
        self.lbFlowName.text = flowDefinition.metadata?.name
        setupQuestion(flowDefinition)
        
        var indexChoices = 0
        for flowRule in (flowDefinition.ruleSets?[0].rules)! {
            let choiceResultView = NSBundle.mainBundle().loadNibNamed("URChoiceResultView", owner: 0, options: nil)[0] as? URChoiceResultView
            
            choiceResultView!.frame = CGRectMake(0, CGFloat(indexChoices * viewChoiceHeight), UIScreen.mainScreen().bounds.width, CGFloat(viewChoiceHeight))
            
            choiceResultView!.lbChoice.text = flowRule.category[flowDefinition.baseLanguage!]
            
            self.viewResponses.addSubview(choiceResultView!)
            indexChoices++
        }
    }
    
    func setupQuestion(flowDefinition: URFlowDefinition) {
        self.tvQuestion.text = flowDefinition.actionSets?[0].actions?[0].message[flowDefinition.baseLanguage!]
        let sizeThatFitsTextView = tvQuestion.sizeThatFits(CGSizeMake(tvQuestion.frame.size.width, CGFloat.max));
        constraintQuestionHeight.constant = sizeThatFitsTextView.height;
    }
    
}

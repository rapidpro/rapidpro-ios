//
//  URFlowManager.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

class URFlowManager {
    
    class func translateFields(contact:URContact, message:String) -> String {
        return message.stringByReplacingOccurrencesOfString("@contact", withString: contact.name!)
    }
    
    class func isFlowActive(flowRun:URFlowRun) -> Bool {
        return flowRun.expired_on != nil
            || (!flowRun.completed && flowRun.expires_on != nil && flowRun.expires_on.timeIntervalSinceDate(NSDate()) > 0)
    }
    
    class func isLastActionSet(actionSet:URFlowActionSet?) -> Bool {
        return actionSet == nil || actionSet?.destination == nil || actionSet!.destination!.isEmpty
    }
    
    class func hasRecursiveDestination(flowDefinition:URFlowDefinition, ruleSet:URFlowRuleset, rule:URFlowRule) -> Bool {
            if rule.destination != nil {
                let actionSet = getFlowActionSetByUuid(flowDefinition,  destination: rule.destination!);
                return actionSet != nil && actionSet?.destination != nil
                    && actionSet?.destination == ruleSet.uuid!
            }
        return false;
    }
    
    class func getFlowActionSetByUuid(flowDefinition: URFlowDefinition, destination: String?) -> URFlowActionSet? {
        for actionSet in flowDefinition.actionSets! {
            if destination != nil && destination == actionSet.uuid! {
                return actionSet
            }
        }
        return nil
    }
    
    class func getRulesetForAction(flowDefinition: URFlowDefinition, actionSet: URFlowActionSet?) -> URFlowRuleset? {
        for ruleSet in flowDefinition.ruleSets! {
            if actionSet != nil && actionSet?.destination != nil
                && actionSet?.destination == ruleSet.uuid {
                    return ruleSet
            }
        }
        return nil
    }

}

//
//  URFlowManager.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

class URFlowManager {
    
    class func translateFields(_ contact:URContact, message:String) -> String {
        return message.replacingOccurrences(of: "@contact", with: contact.name!)
    }
    
    class func isFlowActive(_ flowRun:URFlowRun) -> Bool {
        guard let exit_type = flowRun.exit_type else {
            return true
        }
        return !(exit_type == "completed" || exit_type == "expired")
    }
    
//    class func isFlowExpired(_ flowRun:URFlowRun) -> Bool {
//        return flowRun.expired_on != nil && (flowRun.expires_on.compare(URDateUtil.currentDate() as Date) == ComparisonResult.orderedDescending)
//    }
    
    class func isLastActionSet(_ actionSet:URFlowActionSet?) -> Bool {
        return actionSet == nil || actionSet?.destination == nil || actionSet!.destination!.isEmpty
    }
    
    class func hasRecursiveDestination(_ flowDefinition:URFlowDefinition, ruleSet:URFlowRuleset, rule:URFlowRule) -> Bool {
            if rule.destination != nil {
                let actionSet = getFlowActionSetByUuid(flowDefinition,  destination: rule.destination!, currentActionSet: nil);
                return actionSet != nil && actionSet?.destination != nil && actionSet?.destination == ruleSet.uuid!
            }
        return false;
    }
    
    class func getFlowActionSetByUuid(_ flowDefinition: URFlowDefinition, destination: String?, currentActionSet:URFlowActionSet?) -> URFlowActionSet? {
        for actionSet in flowDefinition.actionSets! {
            if destination != nil && destination == actionSet.uuid! {
                return actionSet
            }
        }
        return nil
//        if let currentActionSet = currentActionSet {
//            let i = flowDefinition.actionSets?.indexOf({$0.uuid == currentActionSet.uuid})
//            
//            if flowDefinition.actionSets?.count >= i!+1 {
//                return flowDefinition.actionSets?[i!+1]
//            }else {
//                return nil
//            }
//            
//        }else {
//            return nil
//        }

    }
    
    class func getRulesetForAction(_ flowDefinition: URFlowDefinition, actionSet: URFlowActionSet?) -> URFlowRuleset? {
        for ruleSet in flowDefinition.ruleSets! {
            if actionSet != nil && actionSet?.destination != nil
                && actionSet?.destination == ruleSet.uuid {
                    return ruleSet
            }
        }
        return nil
    }

}

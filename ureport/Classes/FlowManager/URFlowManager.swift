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
        return (flowRun.completed == false && !URFlowManager.isFlowExpired(flowRun))
    }
    
    class func isFlowExpired(flowRun:URFlowRun) -> Bool {
        return flowRun.expired_on != nil && (flowRun.expires_on.compare(NSDate()) == NSComparisonResult.OrderedDescending)
    }
    
    class func isLastActionSet(actionSet:URFlowActionSet?) -> Bool {
        return actionSet == nil || actionSet?.destination == nil || actionSet!.destination!.isEmpty
    }
    
    class func hasRecursiveDestination(flowDefinition:URFlowDefinition, ruleSet:URFlowRuleset, rule:URFlowRule) -> Bool {
            if rule.destination != nil {
                let actionSet = getFlowActionSetByUuid(flowDefinition,  destination: rule.destination!, currentActionSet: nil);
                return actionSet != nil && actionSet?.destination != nil && actionSet?.destination == ruleSet.uuid!
            }
        return false;
    }
    
    class func getFlowActionSetByUuid(flowDefinition: URFlowDefinition, destination: String?, currentActionSet:URFlowActionSet?) -> URFlowActionSet? {
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

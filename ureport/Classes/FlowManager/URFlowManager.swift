//
//  URFlowManager.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

class URFlowManager {
    
    class func isFlowActive(flowRun:URFlowRun) -> Bool {
        return flowRun.expires_on != nil
            || (!flowRun.completed && flowRun.expires_on != nil && flowRun.expires_on.timeIntervalSinceDate(NSDate()) > 0)
    }
    
    class func hasRecursiveDestination(flowDefinition:URFlowDefinition, ruleSet:URFlowRuleset, rule:URFlowRule) -> Bool {
            if rule.destination != nil {
                let actionSet = getFlowActionSetByUuid(flowDefinition,  destination: rule.destination!);
                return actionSet != nil && actionSet?.destination != nil
                    && actionSet?.destination == ruleSet.uuid!
            }
        return false;
    }
    
    class func getFlowActionSetByUuid(flowDefinition: URFlowDefinition, destination: String) -> URFlowActionSet? {
        for actionSet in flowDefinition.actionSets! {
            if destination == actionSet.uuid! {
                return actionSet
            }
        }
        return nil
    }

}

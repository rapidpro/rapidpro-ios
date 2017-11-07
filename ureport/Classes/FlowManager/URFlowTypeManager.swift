//
//  URFlowTypeManager.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 19/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URFlowTypeManager {
    
    let OpenField: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.openField, validation: "true", message: "Please, fill all the fields")
    let Choice: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.choice, validation: "contains_any", message: "Please, fill all the fields")
    let OpenFieldContains: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.openField, validation: "contains", message: "Please, fill all the fields")
    let OpenFieldNotEmpty: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.openField, validation: "not_empty", message: "Please, fill all the fields")
    let OpenFieldStarts: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.openField, validation: "starts", message: "Please, fill all the fields")
    let OpenFieldRegex: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.openField, validation: "regex", message: "Field invalid, check the instructions")
    let Number: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.number, validation: "number", message: "Numeric field with invalid value")
    let NumberLessThan: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.number, validation: "lt", message: "Numeric field with invalid value, check the instructions")
    let NumberGreaterThan: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.number, validation: "gt", message: "Numeric field with invalid value, check the instructions")
    let NumberBetween: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.number, validation: "between", message: "Numeric field with invalid value, check the instructions")
    let NumberEqual: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.number, validation: "eq", message: "Numeric field with invalid value, check the instructions")
    let Date: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.date, validation: "date", message: "Date field with invalid value, check the instructions")
    let DateBefore: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.date, validation: "date_before", message: "Date field with invalid value, check the instructions")
    let DateAfter: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.date, validation: "date_after", message: "Date field with invalid value, check the instructions")
    let DateEqual: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.date, validation: "date_equal", message: "Date field with invalid value, check the instructions")
    let Phone: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.phone, validation: "phone", message: "Phone with invalid value, check the instructions")
    let State: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.state, validation: "state", message: "State with invalid value, check the instructions")
    let District: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.district, validation: "district", message: "District with invalid value, check the instructions")
    
    let typeValidations: [URFlowTypeValidation]
    
    init() {
        typeValidations = [OpenField, Choice, OpenFieldContains, OpenFieldNotEmpty, OpenFieldStarts, OpenFieldRegex, Number, NumberLessThan, NumberGreaterThan, NumberBetween, NumberEqual, Date, DateBefore, DateAfter, DateEqual, Phone, State, District]
    }
    
    func getTypeValidationForRule(_ flowRule:URFlowRule) -> URFlowTypeValidation {
        return getTypeValidation((flowRule.test?.type)!)
    }
    
    func getTypeValidation(_ validation:String) -> URFlowTypeValidation {
        for typeValidation in self.typeValidations {
            if typeValidation.validation == validation {
                return typeValidation
            }
        }
        return OpenField
    }
    
}

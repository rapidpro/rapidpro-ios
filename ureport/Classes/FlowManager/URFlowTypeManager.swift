//
//  URFlowTypeManager.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 19/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URFlowTypeManager: NSObject {
    
    let OpenField: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.OpenField, validation: "true", message: "Please, fill all the fields")
    let Choice: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Choice, validation: "contains_any", message: "Please, fill all the fields")
    let OpenFieldContains: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.OpenField, validation: "contains", message: "Please, fill all the fields")
    let OpenFieldNotEmpty: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.OpenField, validation: "not_empty", message: "Please, fill all the fields")
    let OpenFieldStarts: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.OpenField, validation: "starts", message: "Please, fill all the fields")
    let OpenFieldRegex: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.OpenField, validation: "regex", message: "Field invalid, check the instructions")
    let Number: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Number, validation: "number", message: "Numeric field with invalid value")
    let NumberLessThan: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Number, validation: "lt", message: "Numeric field with invalid value, check the instructions")
    let NumberGreaterThan: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Number, validation: "gt", message: "Numeric field with invalid value, check the instructions")
    let NumberBetween: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Number, validation: "between", message: "Numeric field with invalid value, check the instructions")
    let NumberEqual: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Number, validation: "eq", message: "Numeric field with invalid value, check the instructions")
    let Date: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Date, validation: "date", message: "Date field with invalid value, check the instructions")
    let DateBefore: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Date, validation: "date_before", message: "Date field with invalid value, check the instructions")
    let DateAfter: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Date, validation: "date_after", message: "Date field with invalid value, check the instructions")
    let DateEqual: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Date, validation: "date_equal", message: "Date field with invalid value, check the instructions")
    let Phone: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.Phone, validation: "phone", message: "Phone with invalid value, check the instructions")
    let State: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.State, validation: "state", message: "State with invalid value, check the instructions")
    let District: URFlowTypeValidation = URFlowTypeValidation(type: URFlowType.District, validation: "district", message: "District with invalid value, check the instructions")
    
}

//
//  GetAllExpressionChildren.swift
//  i2Elevator
//
//  Created by János Kukoda on 25/03/2024.
//

func getLastFunctionSignature(in mapRule: MapRule?, withKeyPath keyPath: [Any]) -> [SignatureProp]? {
    guard var mapRule = mapRule else {
        return nil
    }
    guard var currentExpression = mapRule.objectrule else {
        return nil
    }
    var currentKeypath = keyPath
    var lastFunctionName: String? = nil
    while let (nextExpression, remainingKeypath) = getExpressionByKeypath(expression: currentExpression, keyPath: currentKeypath) {
        if let _lastFunctionName = currentExpression.function?.name {
            lastFunctionName = _lastFunctionName
        }
        currentExpression = nextExpression
        currentKeypath = remainingKeypath
    }
    if let lastFunctionName = lastFunctionName,
       let functionSignature = signatureCategories[0].functions[lastFunctionName]
    {
        return functionSignature
    } else {
        return nil
    }
}

func getExpressionByKeypath(expression: Expression, keyPath: [Any]) -> (Expression, [Any])? {
    if let firstKey = keyPath.first as? String,
       firstKey == "array",
       let array = expression.array,
       keyPath.count >= 2,
       let i = keyPath[1] as? Int
    {
        let nextExpression = array[i]
        return (nextExpression, Array(keyPath.dropFirst(2)))
    } else if let firstKey = keyPath.first as? String,
              firstKey == "function",
              let function = expression.function,
              keyPath.count >= 3,
              let i = keyPath[2] as? Int
    {
        let nextExpression = function.props[i]
        return (nextExpression, Array(keyPath.dropFirst(3)))
    } else {
        return nil
    }
}

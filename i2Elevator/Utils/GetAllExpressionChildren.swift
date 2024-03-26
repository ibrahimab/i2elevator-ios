//
//  GetAllExpressionChildren.swift
//  i2Elevator
//
//  Created by János Kukoda on 25/03/2024.
//

func getAllExpressionChildren(of expression: Expression) -> [Expression] {
    var children: [Expression] = []
    
    if let function = expression.function {
        children.append(expression)
        for prop in function.props {
            children += getAllExpressionChildren(of: prop)
        }
    } else {
        children.append(expression)
    }
    
    return children
}

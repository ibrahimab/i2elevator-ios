//
//  TransformMapRuleToGrid.swift
//  i2Elevator
//
//  Created by János Kukoda on 11/03/2024.
//

import SwiftUI

struct ExpressionRow: Identifiable {
    var index: Int 
    var indentation: Int
    var columns: [ExpressionColumn]
    var id: String {
        "\(index)"
    }
}

struct ExpressionColumn: Identifiable {
    var text: String
    var parentExpression: Expression?
    var expression: Expression?
    var index: Int
    var isBtnStyle: Bool
    var expressionKeypathSegment: [Any]
    var keyToWrite: String?
    var id: String {
        "\(index)"
    }
}

func transformMapRuleToGrid(mapRule: MapRule, schemaItems: [String: SchemaItem]?, rowInd: inout Int, transformation: Transformation?) -> [ExpressionRow] {
    if let subTransformationId = mapRule.subTransformationId,
       let subTransformation = transformation?.subTransformations[subTransformationId]
       //let lastReference = mapRule.objectrule?.reference?.last?.last,
       //let displayName = schemaItems?[lastReference]?.displayName
    {
        var jj = ""
        var i = 0
        for kk in subTransformation.inputs {
            if let schemaItemId = kk.schemaItemId,
               let displayName = schemaItems?[schemaItemId]?.name {
                if i > 0 {
                    jj = jj + ", "
                }
                jj = jj + displayName
                i = i + 1
            }
        }
        let vv2 = ExpressionColumn(text: "=\(subTransformation.name)(\(jj))", index: 0, isBtnStyle: false, expressionKeypathSegment: [])
        let zz3 = ExpressionRow(index: rowInd, indentation: 0, columns: [vv2])
        return [zz3]
    } else {
        return transformExpressionsToGrid(
            prop: mapRule.objectrule,
            indentation: 0,
            keyPath: [],
            schemaItems: schemaItems,
            parentExpression: nil,
            rowInd: &rowInd
        )
    }
}

func transformExpressionsToGrid(
    prop: Expression?,
    indentation: Int,
    keyPath: [Any],
    schemaItems: [String: SchemaItem]?,
    parentExpression: Expression?,
    rowInd: inout Int
) -> [ExpressionRow] {
    var rows: [ExpressionRow] = []
    var columns: [ExpressionColumn] = []
    if indentation == 0 {
        columns.append(ExpressionColumn(text: "=", index: -1, isBtnStyle: false, expressionKeypathSegment: keyPath))
    }
    if prop?.type == "function", let functionProps = prop?.function {
        columns.append(ExpressionColumn(text: functionProps.name, index: 0, isBtnStyle: true, expressionKeypathSegment: keyPath, keyToWrite: "name"))
        columns.append(ExpressionColumn(text: "(", index: 1, isBtnStyle: false, expressionKeypathSegment: keyPath))
        let zz = ExpressionRow(index: rowInd, indentation: indentation, columns: columns)
        rowInd = rowInd + 1
        rows.append(zz)
        for (index, element) in functionProps.props.enumerated() {
            let zz2 = transformExpressionsToGrid(
                prop: element,
                indentation: indentation + 1,
                keyPath: keyPath + ["function", "props", index],
                schemaItems: schemaItems,
                parentExpression: prop,
                rowInd: &rowInd
            )
            rows.append(contentsOf: zz2)
            rowInd = rowInd + 1
        }
        let vv2 = ExpressionColumn(text: ")", index: 2, isBtnStyle: false, expressionKeypathSegment: keyPath)
        let zz3 = ExpressionRow(index: rowInd, indentation: indentation, columns: [vv2])
        rows.append(zz3)
    } else if prop?.type == "reference", let reference = prop?.reference {
        if let displayName = schemaItems?[reference]?.name {
            columns.append(ExpressionColumn(text: "\(displayName)", parentExpression: parentExpression, expression: nil, index: 0, isBtnStyle: true, expressionKeypathSegment: keyPath, keyToWrite: "reference"))
            let zz = ExpressionRow(index: rowInd, indentation: indentation, columns: columns)
            rowInd = rowInd + 1
            rows.append(zz)
        }
    } else if prop?.type == "placeholder" {
        columns.append(ExpressionColumn(text: "placeholder", parentExpression: parentExpression, expression: nil, index: 0, isBtnStyle: true, expressionKeypathSegment: keyPath, keyToWrite: nil))
        let zz = ExpressionRow(index: rowInd, indentation: indentation, columns: columns)
        rowInd = rowInd + 1
        rows.append(zz)
    } else if prop?.type == "constant" {
        columns.append(ExpressionColumn(text: prop?.constant ?? "na", parentExpression: parentExpression, expression: prop, index: 0, isBtnStyle: true, expressionKeypathSegment: keyPath))
        let zz = ExpressionRow(index: rowInd, indentation: indentation, columns: columns)
        rowInd = rowInd + 1
        rows.append(zz)
    }
    if prop?.type == nil {
        var vv = ExpressionColumn(text: "placeholder", parentExpression: parentExpression, expression: nil, index: -1, isBtnStyle: true, expressionKeypathSegment: keyPath, keyToWrite: nil)
        if parentExpression?.type == "function", parentExpression?.function?.name == "LOOKUP", let l = keyPath.last as? Int, l == 0 {
            vv = ExpressionColumn(text: "lookup table", parentExpression: parentExpression, expression: nil, index: 0, isBtnStyle: true, expressionKeypathSegment: keyPath, keyToWrite: nil)
        } else if parentExpression?.type == "function", parentExpression?.function?.name == "LOOKUP", let l = keyPath.last as? Int, l == 1 {
            vv = ExpressionColumn(text: "output field", parentExpression: parentExpression, expression: nil, index: 0, isBtnStyle: true, expressionKeypathSegment: keyPath, keyToWrite: nil)
        } else if parentExpression?.type == "function", parentExpression?.function?.name == "LOOKUP", let l = keyPath.last as? Int, l == 2 {
            vv = ExpressionColumn(text: "input field", parentExpression: parentExpression, expression: nil, index: 0, isBtnStyle: true, expressionKeypathSegment: keyPath, keyToWrite: nil)
        }
        let zz = ExpressionRow(index: rowInd, indentation: indentation, columns: [vv])
        rowInd = rowInd + 1
        rows.append(zz)
    }
    return rows
}

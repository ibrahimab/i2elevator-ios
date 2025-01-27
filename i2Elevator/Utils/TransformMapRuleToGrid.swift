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
    var functionPropIndex: Int?
    var id: String {
        "\(index)"
    }
}

func transformMapRuleToGrid(mapRule: MapRule?, schemaItems: [String: SchemaItem]?, rowInd: inout Int, transformation: Transformation?) -> [ExpressionRow] {
    if let subTransformationId = mapRule?.subTransformationId,
       let subTransformation = transformation?.subTransformations[subTransformationId]
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
        let vv2 = ExpressionColumn(text: "=\(subTransformation.name)(\(jj))", index: 0, isBtnStyle: true, expressionKeypathSegment: [])
        let zz3 = ExpressionRow(index: rowInd, indentation: 0, columns: [vv2])
        return [zz3]
    } else if let mapRule = mapRule {
        return transformExpressionsToGrid(
            expression: mapRule.objectrule,
            indentation: 0,
            keyPath: [],
            schemaItems: schemaItems,
            parentExpression: nil,
            rowInd: &rowInd,
            functionPropIndex: nil
        )
    } else {
        let vv2 = ExpressionColumn(text: "=", index: 0, isBtnStyle: true, expressionKeypathSegment: [])
        let zz3 = ExpressionRow(index: rowInd, indentation: 0, columns: [vv2])
        return [zz3]
    }
}

func transformExpressionsToGrid(
    expression: Expression?,
    indentation: Int,
    keyPath: [Any],
    schemaItems: [String: SchemaItem]?,
    parentExpression: Expression?,
    rowInd: inout Int,
    functionPropIndex: Int?
) -> [ExpressionRow] {
    var rows: [ExpressionRow] = []
    var columns: [ExpressionColumn] = []
    if indentation == 0 {
        columns.append(ExpressionColumn(text: "=", index: 0, isBtnStyle: false, expressionKeypathSegment: keyPath))
    }
    if expression?.type == "function", 
        let functionProps = expression?.function
    {
        columns.append(ExpressionColumn(text: functionProps.name, expression: expression, index: 1, isBtnStyle: true, expressionKeypathSegment: keyPath))
        columns.append(ExpressionColumn(text: "(", index: 2, isBtnStyle: false, expressionKeypathSegment: keyPath))
        let zz = ExpressionRow(index: rowInd, indentation: indentation, columns: columns)
        rowInd = rowInd + 1
        rows.append(zz)
        for (index, element) in functionProps.props.enumerated() {
            var _rows = transformExpressionsToGrid(
                expression: element,
                indentation: indentation + 1,
                keyPath: keyPath + ["function", "props", index],
                schemaItems: schemaItems,
                parentExpression: expression,
                rowInd: &rowInd,
                functionPropIndex: index
            )
            if index < functionProps.props.count - 1 {
                _rows[_rows.count - 1].columns.append(ExpressionColumn(text: ",", index: _rows.count - 1, isBtnStyle: false, expressionKeypathSegment: keyPath))
            }
            rows.append(contentsOf: _rows)
            rowInd = rowInd + 1
        }
        if functionProps.name == "LOOKUP" {
            rows[3].columns.remove(at: 1)
            rows[3].columns.append(ExpressionColumn(text: "=", index: 2, isBtnStyle: false, expressionKeypathSegment: keyPath))
            rows[3].columns.append(contentsOf: rows[4].columns)
            rows[3].columns[2].index = 3
            rows.remove(at: 4)
        } else if functionProps.name == "GROUP" {
            var columns1: [ExpressionColumn] = []
            columns1.append(ExpressionColumn(text: "Add reference or expression to the index", index: 1, isBtnStyle: true, expressionKeypathSegment: keyPath + ["function", "props", 1, "array"]))
            let zz1 = ExpressionRow(index: rowInd, indentation: indentation + 1, columns: columns1)
            rowInd = rowInd + 1
            rows.append(zz1)
        }
        let vv2 = ExpressionColumn(text: ")", index: 3, isBtnStyle: false, expressionKeypathSegment: keyPath)
        let zz3 = ExpressionRow(index: rowInd, indentation: indentation, columns: [vv2])
        rows.append(zz3)
    } else if expression?.type == "array",
              let arrayItems = expression?.array
    {
        columns.append(ExpressionColumn(text: "[", index: 1, isBtnStyle: false, expressionKeypathSegment: keyPath))
        let zz = ExpressionRow(index: rowInd, indentation: indentation, columns: columns)
        rowInd = rowInd + 1
        rows.append(zz)
        for (index, element) in arrayItems.enumerated() {
            var _rows = transformExpressionsToGrid(
                expression: element,
                indentation: indentation + 1,
                keyPath: keyPath + ["array", index],
                schemaItems: schemaItems,
                parentExpression: expression,
                rowInd: &rowInd,
                functionPropIndex: functionPropIndex
            )
            if index < arrayItems.count - 1 {
                _rows[_rows.count - 1].columns.append(ExpressionColumn(text: ",", index: _rows.count - 1, isBtnStyle: false, expressionKeypathSegment: keyPath))
            }
            rows.append(contentsOf: _rows)
            rowInd = rowInd + 1
        }
        let vv2 = ExpressionColumn(text: "]", index: 3, isBtnStyle: false, expressionKeypathSegment: keyPath)
        let zz3 = ExpressionRow(index: rowInd, indentation: indentation, columns: [vv2])
        rows.append(zz3)
    } else if expression?.type == "reference", let lastReference = expression?.reference?.last?.last {
        if let displayName = schemaItems?[lastReference]?.name {
            columns.append(ExpressionColumn(text: "\(displayName)", parentExpression: parentExpression, expression: expression, index: 1, isBtnStyle: true, expressionKeypathSegment: keyPath, functionPropIndex: functionPropIndex))
            let zz = ExpressionRow(index: rowInd, indentation: indentation, columns: columns)
            rowInd = rowInd + 1
            rows.append(zz)
        }
    } else if expression?.type == "placeholder" {
        columns.append(ExpressionColumn(text: "placeholder", parentExpression: parentExpression, expression: expression, index: 1, isBtnStyle: true, expressionKeypathSegment: keyPath, functionPropIndex: functionPropIndex))
        let zz = ExpressionRow(index: rowInd, indentation: indentation, columns: columns)
        rowInd = rowInd + 1
        rows.append(zz)
    } else if expression?.type == "constant" {
        columns.append(ExpressionColumn(text: expression?.constant ?? "na", parentExpression: parentExpression, expression: expression, index: 1, isBtnStyle: true, expressionKeypathSegment: keyPath, functionPropIndex: functionPropIndex))
        let zz = ExpressionRow(index: rowInd, indentation: indentation, columns: columns)
        rowInd = rowInd + 1
        rows.append(zz)
    }
    /*if expression?.type == nil {
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
    }*/
    return rows
}

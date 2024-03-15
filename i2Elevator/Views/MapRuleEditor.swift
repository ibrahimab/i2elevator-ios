//
//  MapRuleEditor.swift
//  i2Elevator
//
//  Created by János Kukoda on 05/03/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct MapRuleEditor: View {
    @EnvironmentObject var sharedState: SharedState
    var body: some View {
        var rowInd = 0
        ZStack {
            TopColorGradient(color: .yellow)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(systemName: "trash")
                    }
                    .clipShape(Circle())
                    .onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                        if let userDTO = sharedState.userDTO,
                           let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
                           let transformationId = sharedState.transformationId,
                           let transformation = transformations[transformationId],
                           let subTransformationId = sharedState.subTransformationId,
                           let _ = transformation.subTransformations[subTransformationId]?.outputs,
                           let cardIndex = sharedState.cardIndex,
                           let cardType = sharedState.cardType,
                           cardType == "out",
                           let outputItemId = sharedState.outputItemId,
                           let expressionKeypathSegment = sharedState.expressionKeypathSegment
                        {
                            let value: [String: Any] = ["type": "placeholder"]
                            let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + expressionKeypathSegment
                            let newUserDTO = updateClient(userDTO: userDTO, value: value, keyPath: keyPath, operation: "setValue")
                            sharedState.userDTO = newUserDTO
                        }
                        sharedState.indentedInputItem = nil
                        return true
                    }
                }
                .padding(.bottom, 40)
                if let userDTO = sharedState.userDTO,
                   let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
                   let transformationId = sharedState.transformationId,
                   let transformation = transformations[transformationId],
                   let subTransformationId = sharedState.subTransformationId,
                   let outputs = transformation.subTransformations[subTransformationId]?.outputs,
                   let cardIndex = sharedState.cardIndex,
                   let cardType = sharedState.cardType,
                   cardType == "out",
                   let mapRules = outputs[cardIndex].mapRules,
                   let outputItemId = sharedState.outputItemId,
                   let mapRule = mapRules[outputItemId]
                {
                    let expressionGrid = transformMapRuleToGrid(mapRule: mapRule, schemaItems: transformation.schemaItems, rowInd: &rowInd, transformation: transformation)
                    ForEach(expressionGrid, id: \.index) { v in
                        HStack {
                            Spacer().frame(width: CGFloat(v.indentation) * 20.0)
                            ForEach(v.columns, id: \.id) { column in
                                if column.isBtnStyle == true {
                                    
                                    // Reference dropped onto a parameter of a function
                                    if let indentedInputItem = sharedState.indentedInputItem,
                                       let functionPropIndex = column.functionPropIndex,
                                       let functionName = column.parentExpression?.function?.name,
                                       functionPropsTypes[functionName]?[functionPropIndex].first(where: { propType in
                                           let ret = propType.type == "reference" && propType.rangeMax == indentedInputItem.rangeMax
                                           return ret
                                       }) != nil
                                    {
                                        Button(action: {
                                        }) {
                                            Text(column.text)
                                                .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                                .foregroundColor(.white)
                                            //.background(b ? Color.green : Color.blue)
                                                .cornerRadius(8)
                                        }.onDrag {
                                            //sharedState.expressionKeypathSegment = column.expressionKeypathSegment
                                            let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                            return itemProvider
                                        }.onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                            var _expression = column.expression
                                            if let schemaItemId = sharedState.indentedInputItem?.schemaItemId {
                                                _expression?.type = "reference"
                                                _expression?.reference = schemaItemId
                                                let jsonEncoder = JSONEncoder()
                                                if let jsonData = try? jsonEncoder.encode(_expression),
                                                   let value = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                                    let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + column.expressionKeypathSegment
                                                    let newUserDTO = updateClient(userDTO: userDTO, value: value, keyPath: keyPath, operation: "setValue")
                                                    sharedState.userDTO = newUserDTO
                                                }
                                            }
                                            sharedState.indentedInputItem = nil
                                            return true
                                        }
                                        
                                        // Function dropped
                                    } else if let newFunctionName = sharedState.newFunctionName,
                                              let newFunctionType = functionPropsTypes[newFunctionName],
                                              (column.functionPropIndex == nil || {
                                                  if let functionPropIndex = column.functionPropIndex,
                                                     let functionName = column.parentExpression?.function?.name,
                                                     functionPropsTypes[functionName]?[functionPropIndex].first(where: { functionType in
                                                         return functionType.type == "function"
                                                     }) != nil
                                                  {
                                                      return true
                                                  } else {
                                                      return false
                                                  }
                                              }())
                                    {
                                        Button(action: {
                                            /*expressionKeypathSegment = column.expressionKeypathSegment
                                             expressionColumn = column
                                             inputSchemaItemId = nil*/
                                        }) {
                                            Text(column.text)
                                                .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                                .foregroundColor(.white)
                                            //.background(b ? Color.green : Color.blue)
                                                .cornerRadius(8)
                                        }.onDrag {
                                            resetDragProperties()
                                            sharedState.expressionKeypathSegment = column.expressionKeypathSegment
                                            let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                            return itemProvider
                                        }.onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                            var _expression = column.parentExpression ?? column.expression
                                            var newProps: [Expression] = []
                                            if _expression?.type == "function",
                                               let prevFunctionName = _expression?.function?.name,
                                               let prevFunctionType = functionPropsTypes[prevFunctionName],
                                               let prevFunctionPropCount = _expression?.function?.props.count
                                            {
                                                // Copy elements from the original array to the resized array
                                                for i in 0..<newFunctionType.count {
                                                    if _expression?.type == "function",
                                                       i < prevFunctionType.count,
                                                       i < newFunctionType.count,
                                                       newFunctionType[i].first(where: { functionPropType in
                                                           let ret = functionPropType.type == _expression?.function?.props[i].type && functionPropType.rangeMax == _expression?.function?.props[i].rangeMax
                                                           return ret
                                                       }) != nil,
                                                       i < prevFunctionPropCount,
                                                       let prevFunctionProp = _expression?.function?.props[i]
                                                    {
                                                        newProps.append(prevFunctionProp)
                                                    } else {
                                                        newProps.append(Expression(type: "placeholder"))
                                                    }
                                                }
                                                _expression?.function?.props = newProps
                                            } else {
                                                for _ in 0..<newFunctionType.count {
                                                    newProps.append(Expression(type: "placeholder"))
                                                }
                                            }
                                            _expression?.function?.name = newFunctionName
                                            _expression?.type = "function"
                                            let jsonEncoder = JSONEncoder()
                                            if let jsonData = try? jsonEncoder.encode(_expression),
                                               let value = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                                
                                                //let value: [String: Any] = ["type": "function", "function": ["name": newFunctionName, "props": props]]
                                                let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + column.expressionKeypathSegment
                                                let newUserDTO = updateClient(userDTO: userDTO, value: value, keyPath: keyPath, operation: "setValue")
                                                sharedState.userDTO = newUserDTO
                                            }
                                            sharedState.newFunctionName = nil
                                            return true
                                        }
                                    } else {
                                        Button(action: {
                                            /*expressionKeypathSegment = column.expressionKeypathSegment
                                             expressionColumn = column
                                             inputSchemaItemId = nil*/
                                        }) {
                                            Text(column.text)
                                                .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                                .foregroundColor(.white)
                                            //.background(b ? Color.green : Color.blue)
                                                .cornerRadius(8)
                                        }.onDrag {
                                            resetDragProperties()
                                            sharedState.expressionKeypathSegment = column.expressionKeypathSegment
                                            let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                            return itemProvider
                                        }
                                    }
                                } else {
                                    Text(column.text)
                                }
                            }
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 20)
        }
    }
}

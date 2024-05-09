//
//  MapRuleEditor.swift
//  i2Elevator
//
//  Created by János Kukoda on 05/03/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture

struct MapRuleEditor: View {
    @EnvironmentObject var sharedState: SharedState
    @State private var text: String = ""
    @State private var isEditing: Bool = false
    let store: StoreOf<UserFeature>
    
    var body: some View {
        var rowInd = 0
        if let subTransformationId = sharedState.subTransformationId,
            sharedState.menu == .subTransformation
        {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Image(systemName: "trash")
                        }
                        .clipShape(Circle())
                        .onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                            if let _draggedSchemaItem = sharedState.draggedSchemaItem,
                               let i = sharedState.schemaItemsOnScratchpad.firstIndex(where: { draggedSchemaItem in
                                   draggedSchemaItem.schemaItemId == _draggedSchemaItem.schemaItemId
                               })
                            {
                                sharedState.schemaItemsOnScratchpad.remove(at: i)
                            } else if let userDTO = store.userDTO,
                                      let transformations = store.userDTO?.teams?["response"]?.transformations,
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
                                store.send(.setValue(keyPath: keyPath, value: value))
                            }
                            sharedState.draggedSchemaItem = nil
                            return true
                        }
                    }
                    if let userDTO = store.userDTO,
                       let transformations = store.userDTO?.teams?["response"]?.transformations,
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
                                        // If this parameter is const
                                        if let parentExpression = column.parentExpression,
                                           let functionName = parentExpression.function?.name,
                                           let functionPropIndex = column.functionPropIndex,
                                           signatureCategories.first(where: { fp in
                                               let ret = fp.functions[functionName]?[functionPropIndex].first(where: { signatureItemVariant in
                                                   let ret = signatureItemVariant.type == "constant"
                                                   return ret
                                               })
                                               return ret != nil
                                           }) != nil
                                        {
                                            TextField("constant", text: $text, onEditingChanged: { editing in
                                                self.isEditing = editing
                                                if !editing {
                                                    // Text field is closed, perform any necessary actions here
                                                    let value = ["type": "constant", "constant": text]
                                                    let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + column.expressionKeypathSegment
                                                    store.send(.setValue(keyPath: keyPath, value: value))
                                                }
                                            })
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .frame(width: 200)
                                            // Reference dropped onto a parameter of a function
                                        } else if let draggedSchemaItem = sharedState.draggedSchemaItem,
                                                  let functionPropIndex = column.functionPropIndex,
                                                  let functionName = column.parentExpression?.function?.name,
                                                  signatureCategories[sharedState.functionCategoryIndex].functions[functionName]?[functionPropIndex].first(where: { propType in
                                                      let ret = propType.type == "reference" && propType.rangeMax == draggedSchemaItem.rangeMax
                                                      return ret
                                                  }) != nil
                                        {
                                            Button(action: {
                                            }) {
                                                Text(column.text)
                                            }.onDrag {
                                                //sharedState.expressionKeypathSegment = column.expressionKeypathSegment
                                                let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                                return itemProvider
                                            }.onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                                var _expression = column.expression
                                                if let schemaItemId = sharedState.draggedSchemaItem?.schemaItemId
                                                {
                                                    _expression?.type = "reference"
                                                    _expression?.reference = schemaItemId
                                                    _expression?.rangeMax = draggedSchemaItem.rangeMax
                                                    let jsonEncoder = JSONEncoder()
                                                    if let jsonData = try? jsonEncoder.encode(_expression),
                                                       let value = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                                        let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + column.expressionKeypathSegment
                                                        store.send(.setValue(keyPath: keyPath, value: value))
                                                    }
                                                }
                                                sharedState.draggedSchemaItem = nil
                                                return true
                                            }.buttonStyle(BorderedButtonStyle())
                                            
                                            // Function dropped
                                        } else if let newFunctionName = sharedState.draggedFunctionName,
                                                  let newFunctionType =  signatureCategories[sharedState.functionCategoryIndex].functions[newFunctionName],
                                                  (column.functionPropIndex == nil || {
                                                      if let functionPropIndex = column.functionPropIndex,
                                                         let functionName = column.parentExpression?.function?.name/*,
                                                                                                                    functionPropsTypes[sharedState.functionCategoryIndex].functions[functionName]?[functionPropIndex].first(where: { functionType in
                                                                                                                    return functionType.type == "function"
                                                                                                                    }) != nil*/
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
                                            }.onDrag {
                                                resetDragProperties()
                                                sharedState.expressionKeypathSegment = column.expressionKeypathSegment
                                                let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                                return itemProvider
                                            }.onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                                var _expression = column.expression
                                                var newProps: [Expression] = []
                                                if column.expression?.type == "function",
                                                   let prevFunctionName = column.expression?.function?.name,
                                                   let prevFunctionType = signatureCategories[sharedState.functionCategoryIndex].functions[prevFunctionName],
                                                   let prevFunctionPropCount =  column.expression?.function?.props.count
                                                {
                                                    // Copy elements from the original array to the resized array
                                                    for i in 0..<newFunctionType.count {
                                                        if i < prevFunctionType.count,
                                                           newFunctionType[i].first(where: { functionPropType in
                                                               let ret = functionPropType.type == column.expression?.function?.props[i].type && functionPropType.rangeMax == column.expression?.function?.props[i].rangeMax
                                                               return ret
                                                           }) != nil,
                                                           i < prevFunctionPropCount,
                                                           let prevFunctionProp =  column.expression?.function?.props[i]
                                                        {
                                                            newProps.append(prevFunctionProp)
                                                        } else {
                                                            newProps.append(Expression(type: "placeholder"))
                                                        }
                                                    }
                                                } else {
                                                    for _ in 0..<newFunctionType.count {
                                                        newProps.append(Expression(type: "placeholder"))
                                                    }
                                                }
                                                _expression?.function = Function(name: newFunctionName, props: newProps)
                                                _expression?.type = "function"
                                                if let expression = column.expression {
                                                    let childExpressions = getAllExpressionChildren(of: expression)
                                                    for childExpression in childExpressions {
                                                        if childExpression.type == "reference",
                                                           let referenceToAddToScratchpad = childExpression.reference,
                                                           let schemaItem = userDTO.teams?["response"]?.transformations[transformationId]?.schemaItems[referenceToAddToScratchpad],
                                                           let rangeMaxToAddToScratchpad = childExpression.rangeMax,
                                                           sharedState.schemaItemsOnScratchpad.first(where: { schemaItemOnScratchpad in
                                                               schemaItemOnScratchpad.schemaItemId == referenceToAddToScratchpad
                                                           }) == nil {
                                                            sharedState.schemaItemsOnScratchpad.append(DraggedSchemaItem(schemaItemId: referenceToAddToScratchpad, rangeMax: rangeMaxToAddToScratchpad, numOfChildren: schemaItem.children.count))
                                                        }
                                                    }
                                                }
                                                let jsonEncoder = JSONEncoder()
                                                if let jsonData = try? jsonEncoder.encode(_expression),
                                                   let value = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                                    
                                                    //let value: [String: Any] = ["type": "function", "function": ["name": newFunctionName, "props": props]]
                                                    let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + column.expressionKeypathSegment
                                                    store.send(.setValue(keyPath: keyPath, value: value))
                                                }
                                                sharedState.draggedFunctionName = nil
                                                return true
                                            }.buttonStyle(BorderedButtonStyle())
                                        } else {
                                            Button(action: {
                                                /*expressionKeypathSegment = column.expressionKeypathSegment
                                                 expressionColumn = column
                                                 inputSchemaItemId = nil*/
                                            }) {
                                                Text(column.text)
                                            }.onDrag {
                                                resetDragProperties()
                                                sharedState.expressionKeypathSegment = column.expressionKeypathSegment
                                                let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                                return itemProvider
                                            }.buttonStyle(BorderedButtonStyle())
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
                    VStack {
                        HStack {
                            Spacer().frame(width: 20.0)
                            Text("Scratchpad")
                            Spacer()
                        }
                        ForEach(sharedState.schemaItemsOnScratchpad.indices, id: \.self) { index in
                            let schemaItemOnScratchpad = sharedState.schemaItemsOnScratchpad[index]
                            HStack {
                                Button(action: {
                                    
                                }) {
                                    if schemaItemOnScratchpad.numOfChildren == 0 {
                                        Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
                                    } else {
                                        Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
                                    }
                                    Spacer().frame(width: 20.0)
                                    if let transformations = store.userDTO?.teams?["response"]?.transformations,
                                       let transformationId = sharedState.transformationId,
                                       let schemaItem = transformations[transformationId]?.schemaItems[schemaItemOnScratchpad.schemaItemId],
                                       let rangeMax = schemaItemOnScratchpad.rangeMax
                                    {
                                        Text("\(schemaItem.name) 1:\(rangeMax)")
                                    }
                                }.onDrag {
                                    resetDragProperties()
                                    sharedState.draggedSchemaItem = schemaItemOnScratchpad
                                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                    return itemProvider
                                }
                                Spacer()
                            }
                        }
                    }.onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                        if let draggedSchemaItem = sharedState.draggedSchemaItem {
                            if sharedState.schemaItemsOnScratchpad.first(where: { schemaItemOnScratchpad in
                                schemaItemOnScratchpad.schemaItemId == draggedSchemaItem.schemaItemId
                            }) == nil {
                                sharedState.schemaItemsOnScratchpad.append(DraggedSchemaItem(schemaItemId: draggedSchemaItem.schemaItemId, rangeMax: draggedSchemaItem.rangeMax, numOfChildren: draggedSchemaItem.numOfChildren))
                            }
                        }
                        sharedState.draggedSchemaItem = nil
                        return true
                    }
                    Spacer()
                }
                .padding()
            } else {
                List {
                    if let transformationId = sharedState.transformationId,
                       let c = store.userDTO?.teams?["response"]?.transformations[transformationId]?.inputExpectedOutputTextIdPairs?.count,
                       c > 0,
                       let a = store.userDTO?.teams?["response"]?.transformations[transformationId]?.inputExpectedOutputTextIdPairs,
                       let expectedOutputTextId = a[0].expectedOutputTextId,
                       let expectedOutputText = store.userDTO?.teams?["response"]?.texts?[expectedOutputTextId] as? String {
                        Section(header: Text("Expected output")) {
                            Text(expectedOutputText)
                        }
                    }
                    if let str = sharedState.output?["output"] as? String {
                        Section(header: Text("Output")) {
                            Text(str)
                        }
                    }
                }.padding()
            }
        }
    
}

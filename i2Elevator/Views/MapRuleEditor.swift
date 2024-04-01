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
            NavigationView {
                List {
                    ForEach(functionPropsTypes.indices, id: \.self) { index in
                        Section(header: Text(functionPropsTypes[index].name)) {
                            ForEach(Array(functionPropsTypes[index].functions.keys.sorted()), id: \.self) { key in
                                Button(action: {
                                    sharedState.selectedFunctionName = key
                                }) {
                                    Text(key)
                                }.onDrag {
                                    resetDragProperties()
                                    sharedState.draggedFunctionName = key
                                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                    return itemProvider
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                .navigationTitle("Rule Editor")
                VStack {
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
                                        if let draggedSchemaItem = sharedState.draggedSchemaItem,
                                           let functionPropIndex = column.functionPropIndex,
                                           let functionName = column.parentExpression?.function?.name,
                                           functionPropsTypes[sharedState.functionCategoryIndex].functions[functionName]?[functionPropIndex].first(where: { propType in
                                               let ret = propType.type == "reference" && propType.rangeMax == draggedSchemaItem.rangeMax
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
                                                if let schemaItemId = sharedState.draggedSchemaItem?.schemaItemId
                                                {
                                                    _expression?.type = "reference"
                                                    _expression?.reference = schemaItemId
                                                    _expression?.rangeMax = draggedSchemaItem.rangeMax
                                                    let jsonEncoder = JSONEncoder()
                                                    if let jsonData = try? jsonEncoder.encode(_expression),
                                                       let value = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                                        let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + column.expressionKeypathSegment
                                                        let newUserDTO = updateClient(userDTO: userDTO, value: value, keyPath: keyPath, operation: "setValue")
                                                        sharedState.userDTO = newUserDTO
                                                    }
                                                }
                                                sharedState.draggedSchemaItem = nil
                                                return true
                                            }
                                            
                                            // Function dropped
                                        } else if let newFunctionName = sharedState.draggedFunctionName,
                                                  let newFunctionType =  functionPropsTypes[sharedState.functionCategoryIndex].functions[newFunctionName],
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
                                                var _expression = column.expression
                                                var newProps: [Expression] = []
                                                if column.expression?.type == "function",
                                                   let prevFunctionName = column.expression?.function?.name,
                                                   let prevFunctionType = functionPropsTypes[sharedState.functionCategoryIndex].functions[prevFunctionName],
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
                                                    let newUserDTO = updateClient(userDTO: userDTO, value: value, keyPath: keyPath, operation: "setValue")
                                                    sharedState.userDTO = newUserDTO
                                                }
                                                sharedState.draggedFunctionName = nil
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
                                    if let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
                                       let transformationId = sharedState.transformationId,
                                       let schemaItem = transformations[transformationId]?.schemaItems[schemaItemOnScratchpad.schemaItemId]
                                    {
                                        Text("\(schemaItem.name) 1:\(schemaItemOnScratchpad.rangeMax)")
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
                .navigationBarItems(
                    leading:  HStack {
                        Button(action: {
                            
                        }) {
                            Image(systemName: "chevron.left")
                        }
                        .clipShape(Circle())
                        
                        Button(action: {
                            
                        }) {
                            Image(systemName: "chevron.right")
                        }
                        .clipShape(Circle())
                    },
                    trailing: HStack {
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
                            } else if let userDTO = sharedState.userDTO,
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
                            sharedState.draggedSchemaItem = nil
                            return true
                        }
                    }
                )
                
            }
        }
    }
}

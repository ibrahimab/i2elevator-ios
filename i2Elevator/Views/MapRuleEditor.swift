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
                           let outputs = transformation.subTransformations[subTransformationId]?.outputs,
                           let cardIndex = sharedState.cardIndex,
                           let cardType = sharedState.cardType,
                           cardType == "out",
                           let mapRules = outputs[cardIndex].mapRules,
                           let outputItemId = sharedState.outputItemId,
                           let expressionKeypathSegment = sharedState.expressionKeypathSegment
                        {
                            let value: [String: Any] = ["type": "placeholder"]
                            let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + expressionKeypathSegment
                            let newUserDTO = updateClient(userDTO: userDTO, value: value, keyPath: keyPath, operation: "setValue")
                            sharedState.userDTO = newUserDTO
                            sharedState.indentedInputItem = nil
                        }
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
                                        sharedState.expressionKeypathSegment = column.expressionKeypathSegment
                                        let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                        return itemProvider
                                    }.onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                        if let newFunctionName = sharedState.newFunctionName {
                                            var props = [[String: Any]]()
                                            let dictionaryToAdd = ["type": "placeholder"]
                                            var numberOfTimesToAdd: Int = 1
                                            if newFunctionName == "LOOKUP" {
                                                numberOfTimesToAdd = 3
                                            }
                                            for _ in 1...numberOfTimesToAdd {
                                                props.append(dictionaryToAdd)
                                            }
                                            let value: [String: Any] = ["type": "function", "function": ["name": newFunctionName, "props": props]]
                                            let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + column.expressionKeypathSegment
                                            let newUserDTO = updateClient(userDTO: userDTO, value: value, keyPath: keyPath, operation: "setValue")
                                            sharedState.userDTO = newUserDTO
                                            sharedState.newFunctionName = nil
                                        } else if let schemaItemId = sharedState.indentedInputItem?.schemaItemId {
                                            let value: [String: Any] = ["type": "reference", "reference": schemaItemId]
                                            let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + column.expressionKeypathSegment
                                            let newUserDTO = updateClient(userDTO: userDTO, value: value, keyPath: keyPath, operation: "setValue")
                                            sharedState.userDTO = newUserDTO
                                            sharedState.indentedInputItem = nil
                                        }
                                        return true
                                    }
                                } else {
                                    Text(column.text)
                                }
                            }
                            Spacer()
                        }.onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                            /*DispatchQueue.main.async {
                             saveSubTransformation()
                             }*/
                            return true
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

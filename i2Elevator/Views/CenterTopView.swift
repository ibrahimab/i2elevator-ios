//
//  MapRuleEditor.swift
//  i2Elevator
//
//  Created by János Kukoda on 05/03/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture
import Combine

struct CenterTopView: View {
    @EnvironmentObject var sharedState: SharedState
    @State private var text: String = ""
    @State private var isEditing: Bool = false
    let store: StoreOf<UserFeature>
    @State private var inputText: String = ""
    @State private var expectedOutputText: String = ""
    @State private var showDocumentPicker = false
    @State private var filename: String?
    @State private var documentDataTypeTree: Data? = nil
    @State private var documentDataTransformation: Data? = nil
    @State private var transformationName: String = ""
    
    func initializeTextViewVariables(inputExpectedOutputPairId: String?, transformationId: String) {
        if let inputExpectedOutputPairId = inputExpectedOutputPairId,
           //let c = store.userDTO?.teams?["response"]?.transformations[transformationId]?.inputExpectedOutputTextIdPairs?.count,
           //c > inputExpectedOutputPairId,
           let a = store.userDTO?.teams?["response"]?.transformations[transformationId]?.inputExpectedOutputTextIdPairs
        {
            if let inputTextId = a[inputExpectedOutputPairId]?.inputTextId
            {
                if let _inputText = store.userDTO?.teams?["response"]?.texts?[inputTextId] as? String {
                    inputText = String(_inputText.dropFirst())
                } else {
                    inputText = ""
                }
            }
            if let expectedOutputTextId = a[inputExpectedOutputPairId]?.expectedOutputTextId {
                if let _expectedOutputText = store.userDTO?.teams?["response"]?.texts?[expectedOutputTextId] as? String {
                    expectedOutputText = String(_expectedOutputText.dropFirst())
                } else {
                    expectedOutputText = ""
                }
            }
        }
    }
    
    func initializeTransformationName(transformationId: String) {
        if let _transformationName = store.userDTO?.teams?["response"]?.transformations[transformationId]?.name
        {
            transformationName = _transformationName
        }
    }
    
    var body: some View {
        var rowInd = 0
        if let _ = sharedState.subTransformationId,
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
                        } else if let _ = store.userDTO,
                                  let transformations = store.userDTO?.teams?["response"]?.transformations,
                                  let transformationId = sharedState.transformationId,
                                  let transformation = transformations[transformationId],
                                  let subTransformationId = sharedState.subTransformationId,
                                  let _ = transformation.subTransformations[subTransformationId]?.outputs,
                                  let cardIndex = sharedState.cardIndex,
                                  let cardType = sharedState.cardType,
                                  cardType == "out",
                                  let outputItemId = sharedState.selectedSchemaItemId,
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
                   let outputItemId = sharedState.selectedSchemaItemId
                {
                    let mapRule = mapRules[outputItemId]
                    let expressionGrid = transformMapRuleToGrid(mapRule: mapRule, schemaItems: transformation.schemaItems, rowInd: &rowInd, transformation: transformation)
                    ForEach(expressionGrid, id: \.index) { v in
                        HStack {
                            Spacer().frame(width: CGFloat(v.indentation) * 20.0)
                            ForEach(v.columns, id: \.id) { column in
                                let lastFunctionSignature = getLastFunctionSignature(in: mapRule, withKeyPath: column.expressionKeypathSegment)
                                if column.isBtnStyle == true {
                                    // If this parameter is const
                                    if v.indentation == v.indentation,
                                       let parentExpression = column.parentExpression,
                                       let functionName = parentExpression.function?.name,
                                       let functionPropIndex = column.functionPropIndex,
                                       signatureCategories.first(where: { fp in
                                           let ret = fp.functions[functionName]?[functionPropIndex].variations.first(where: { signatureItemVariant in
                                               let ret = signatureItemVariant.type == "constant"
                                               return ret
                                           })
                                           return ret != nil
                                       }) != nil
                                    {
                                        ConstantTextField(
                                            store: store,
                                            transformationId: transformationId,
                                            subTransformationId: subTransformationId,
                                            cardIndex: cardIndex,
                                            outputItemId: outputItemId,
                                            column: column
                                        )
                                        .environmentObject(SharedState())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .frame(width: 200)
                                        // Reference dropped onto a parameter of a function
                                    } else if let draggedSchemaItem = sharedState.draggedSchemaItem,
                                              let mapRule = mapRule,
                                              let functionPropIndex = column.functionPropIndex,
                                              let lastFunctionSignature = lastFunctionSignature,
                                              functionPropIndex < lastFunctionSignature.count,
                                              lastFunctionSignature[functionPropIndex].variations.first(where: { propType in
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
                                            if let _ = sharedState.draggedSchemaItem?.schemaItemId,
                                               let reference = sharedState.draggedSchemaItem?.reference
                                            {
                                                _expression?.type = "reference"
                                                _expression?.reference = reference
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
                                              let newFunctionTypeParams =  signatureCategories[sharedState.functionCategoryIndex].functions[newFunctionName],
                                              (column.functionPropIndex == nil || {
                                                  if let _ = column.functionPropIndex,
                                                     let _ = column.parentExpression?.function?.name/*,
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
                                            if _expression == nil {
                                                _expression = Expression(type: nil, function: nil, reference: nil, rangeMax: nil, constant: nil)
                                            }
                                            var newProps: [Expression] = []
                                            if column.expression?.type == "function",
                                               let prevFunctionName = column.expression?.function?.name,
                                               let prevFunctionType = signatureCategories[sharedState.functionCategoryIndex].functions[prevFunctionName],
                                               let prevFunctionPropCount =  column.expression?.function?.props.count
                                            {
                                                // Copy elements from the original array to the resized array
                                                for i in 0..<newFunctionTypeParams.count {
                                                    if i < prevFunctionType.count,
                                                       newFunctionTypeParams[i].variations.first(where: { functionPropType in
                                                           let ret = functionPropType.type == column.expression?.function?.props[i].type && functionPropType.rangeMax == column.expression?.function?.props[i].rangeMax
                                                           return ret
                                                       }) != nil,
                                                       i < prevFunctionPropCount,
                                                       let prevFunctionProp =  column.expression?.function?.props[i]
                                                    {
                                                        newProps.append(prevFunctionProp)
                                                    } else if newFunctionTypeParams[i].type == "array" {
                                                        newProps.append(Expression(type: "array", array: []))
                                                    } else {
                                                        newProps.append(Expression(type: "placeholder"))
                                                    }
                                                }
                                            } else {
                                                for i in 0..<newFunctionTypeParams.count {
                                                    if newFunctionTypeParams[i].type == "array" {
                                                        newProps.append(Expression(type: "array", array: []))
                                                    } else {
                                                        newProps.append(Expression(type: "placeholder"))
                                                    }
                                                }
                                            }
                                            _expression?.function = Function(name: newFunctionName, props: newProps)
                                            _expression?.type = "function"
                                            if let expression = column.expression {
                                                let childExpressions = getAllExpressionChildren(of: expression)
                                                for childExpression in childExpressions {
                                                    if childExpression.type == "reference",
                                                       let referenceToAddToScratchpad = childExpression.reference,
                                                       let lastReferenceToAddToScratchpad = referenceToAddToScratchpad.last?.last,
                                                       let schemaItem = userDTO.teams?["response"]?.transformations[transformationId]?.schemaItems[lastReferenceToAddToScratchpad],
                                                       let rangeMaxToAddToScratchpad = childExpression.rangeMax,
                                                       sharedState.schemaItemsOnScratchpad.first(where: { schemaItemOnScratchpad in
                                                           schemaItemOnScratchpad.schemaItemId == lastReferenceToAddToScratchpad
                                                       }) == nil
                                                    {
                                                        sharedState.schemaItemsOnScratchpad.append(DraggedSchemaItem(schemaItemId: lastReferenceToAddToScratchpad, rangeMax: rangeMaxToAddToScratchpad, numOfChildren: schemaItem.children.count, reference: referenceToAddToScratchpad)) //?? referenceToAddToScratchpad
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
                                            
                                            // TODO: Change later
                                            if column.text == "Add reference or expression to the index" {
                                                // Az array-hoz adjunk hozzá egy új expressiont, placeholder típussal
                                                
                                                let value: [String: Any] = ["type": "placeholder"]
                                                let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] +  column.expressionKeypathSegment
                                                store.send(.push(keyPath: keyPath, value: value))
                                            }
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
                            sharedState.schemaItemsOnScratchpad.append(DraggedSchemaItem(schemaItemId: draggedSchemaItem.schemaItemId, rangeMax: draggedSchemaItem.rangeMax, numOfChildren: draggedSchemaItem.numOfChildren, reference: draggedSchemaItem.reference))
                        }
                    }
                    sharedState.draggedSchemaItem = nil
                    return true
                }
                Spacer()
            }
            .padding()
        } else if let transformationId = sharedState.transformationId,
                  sharedState.menu == .inputExpectedOutputPair,
                  let inputExpectedOutputPairId = sharedState.inputExpectedOutputPairId
        {
            List {
                if //let c = store.userDTO?.teams?["response"]?.transformations[transformationId]?.inputExpectedOutputTextIdPairs?.count,
                   //c > inputExpectedOutputPairId,
                   let inputExpectedOutputTextIdPairs = store.userDTO?.teams?["response"]?.transformations[transformationId]?.inputExpectedOutputTextIdPairs
                {
                    if let inputTextId = inputExpectedOutputTextIdPairs[inputExpectedOutputPairId]?.inputTextId {
                        Section(header: Text("Input")) {
                            TextEditor(text: $inputText)
                                .frame(minHeight: 100)
                                .onChange(of: inputText) { old, new in
                                    let value: String = "#" + new
                                    let keyPath: [Any] = ["response", "texts", inputTextId]
                                    store.send(.setValue(keyPath: keyPath, value: value))
                                }
                        }
                    }
                    if let expectedOutputTextId = inputExpectedOutputTextIdPairs[inputExpectedOutputPairId]?.expectedOutputTextId {
                        Section(header: Text("Expected output")) {
                            TextEditor(text: $expectedOutputText)
                                .frame(minHeight: 100)
                                .onChange(of: expectedOutputText) { old, new in
                                    let value: String = "#" + new
                                    let keyPath: [Any] = ["response", "texts", expectedOutputTextId]
                                    store.send(.setValue(keyPath: keyPath, value: value))
                                }
                        }
                    }
                }
                if let str = sharedState.runTransformationReturn?["output"] as? String {
                    Section(header: Text("Output")) {
                        Text(str)
                    }
                }
            }
            .padding()
            .onChange(of: sharedState.inputExpectedOutputPairId, initial: true) { old, inputExpectedOutputPairId in
                initializeTextViewVariables(inputExpectedOutputPairId: inputExpectedOutputPairId, transformationId: transformationId)
            }
        } else if let transformationId = sharedState.transformationId,
                    self.sharedState.menu == .tags
        {
            List {
                Text("Apple")
                Text("Banana")
            }
            .padding()
        } else if let transformationId = sharedState.transformationId
        {
            List {
                Section(header: Text("Transformation Name")) {
                    TextField("Enter Transformation Name", text: $transformationName)
                        .onChange(of: transformationName) { old, new in
                            let value: String = new
                            let keyPath: [Any] = ["response", "transformations", transformationId, "name"]
                            store.send(.setValue(keyPath: keyPath, value: value))
                        }
                }
                Section(header: Text("External TypeTree updated at")) {
                    if let externalTypeTreeUpdatedAt = store.userDTO?.teams?["response"]?.transformations[transformationId]?.externalTypeTreeUpdatedAt
                    {
                        Text(externalTypeTreeUpdatedAt)
                    } else {
                        Text("")
                    }
                    Button(action: {
                        self.showDocumentPicker.toggle()
                    }) {
                        Text("Import external xml typetree")
                    }
                    .sheet(isPresented: $showDocumentPicker) {
                        DocumentPickerViewController(isPresented: self.$showDocumentPicker, documentData: self.$documentDataTypeTree, filename: $filename)
                    }.onReceive(Just(documentDataTypeTree)) { documentData in
                        guard let documentData = documentData else { return }
                        let value = String(data: documentData, encoding: .utf8) ?? ""
                        let keyPath: [Any] = ["response", "transformations", transformationId, "externalTypeTree"]
                        store.send(.setValue(keyPath: keyPath, value: value))
                        let currentDate = Date()
                        let isoFormatter = ISO8601DateFormatter()
                        let value2 = isoFormatter.string(from: currentDate)
                        let keyPath2: [Any] = ["response", "transformations", transformationId, "externalTypeTreeUpdatedAt"]
                        store.send(.setValue(keyPath: keyPath2, value: value2))
                    }
                }
                Section(header: Text("External Transformation updated at")) {
                    if let externalTransformationUpdatedAt = store.userDTO?.teams?["response"]?.transformations[transformationId]?.externalTransformationUpdatedAt
                    {
                        Text(externalTransformationUpdatedAt)
                    } else {
                        Text("")
                    }
                    Button(action: {
                        self.showDocumentPicker.toggle()
                    }) {
                        Text("Import external xml transformation")
                    }
                    .sheet(isPresented: $showDocumentPicker) {
                        DocumentPickerViewController(isPresented: self.$showDocumentPicker, documentData: self.$documentDataTransformation, filename: $filename)
                    }.onReceive(Just(documentDataTransformation)) { documentData in
                        guard let documentData = documentData else { return }
                        let value = String(data: documentData, encoding: .utf8) ?? ""
                        let keyPath: [Any] = ["response", "transformations", transformationId, "externalTransformation"]
                        store.send(.setValue(keyPath: keyPath, value: value))
                        let currentDate = Date()
                        let isoFormatter = ISO8601DateFormatter()
                        let value2 = isoFormatter.string(from: currentDate)
                        let keyPath2: [Any] = ["response", "transformations", transformationId, "externalTransformationUpdatedAt"]
                        store.send(.setValue(keyPath: keyPath2, value: value2))
                    }
                }
                Section(header: Text("Tags")) {
                    HStack {
                        Button(action: {
                        }) {
                            Text("#itx")
                        }
                        Button(action: {
                            
                        }) {
                            Text("#tutorial")
                        }
                        Spacer()
                        Button(action: {
                            self.sharedState.menu = .tags
                        }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
            .padding()
            .onChange(of: transformationId, initial: true) { old, new in
                initializeTransformationName(transformationId: new)
            }
        } else {
            List {
            }.padding()
        }
    }
}

//
//  CardView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture

struct CardView: View {
    var cardIndex: Int
    var cardType: String
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.openWindow) private var openWindow
    let store: StoreOf<UserFeature>

    func updateIndentedSchemaItemList() -> [IndentedSchemaItem] {
        if let transformations = store.userDTO?.teams?["response"]?.transformations,
           let transformationId = sharedState.transformationId,
           let transformation = transformations[transformationId],
           let subTransformationId = sharedState.subTransformationId,
           let cards = cardType == "in" ? transformation.subTransformations[subTransformationId]?.inputs : transformation.subTransformations[subTransformationId]?.outputs,
           let userDTO = store.userDTO,
           cardIndex < cards.count
        {
            let a = transformSchemaEntityTreeToList(schemaItemId: cards[cardIndex].schemaItemId, userDTO: userDTO, transformationId: sharedState.transformationId, indentation: 1)
            return a
        } else {
            return []
        }
    }
    
    @ViewBuilder
    func inputCardItem(for indentedSchemaItem: IndentedSchemaItem, transformation: Transformation, cards: [Card]) -> some View {
        HStack {
            Spacer().frame(width: CGFloat(indentedSchemaItem.indentation + 1) * 20.0)
            if indentedSchemaItem.numOfChildren == 0 {
                Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
            } else {
                Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
            }
            Spacer().frame(width: 20.0)
            if let schemaItem = transformation.schemaItems[indentedSchemaItem.schemaItemId] {
                Text("\(schemaItem.name) 1:\(indentedSchemaItem.rangeMax)")
                    .foregroundColor(indentedSchemaItem.indentation == 1 ? .white : .gray)
            }
            Spacer()
            if let mapRule = cards[cardIndex].mapRules?[indentedSchemaItem.schemaItemId],
               let objectrule = mapRule.objectrule,
               let reference = objectrule.reference,
               objectrule.type == "reference",
               let targetName = transformation.schemaItems[reference]?.name
            {
                Text(targetName)
            }
        }
    }
    
    @ViewBuilder
    func outputCardItem(for indentedSchemaItem: IndentedSchemaItem, transformation: Transformation, cards: [Card]) -> some View {
        HStack {
            Spacer().frame(width: CGFloat((indentedSchemaItem.indentation + 1)) * 20.0)
            if indentedSchemaItem.numOfChildren == 0 {
                Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
            } else {
                Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
            }
            Spacer().frame(width: 20.0)
            if let schemaItem = transformation.schemaItems[indentedSchemaItem.schemaItemId] {
                Text("\(schemaItem.name) 1:\(indentedSchemaItem.rangeMax)")
                    .fontWeight(sharedState.outputItemId == indentedSchemaItem.schemaItemId ? .bold : .regular)
                    .foregroundColor(indentedSchemaItem.indentation == 1 ? .white : .gray)
            }
            Spacer()
            if let mapRule = cards[cardIndex].mapRules?[indentedSchemaItem.schemaItemId],
               let objectrule = mapRule.objectrule,
               let reference = objectrule.reference,
               objectrule.type == "reference",
               let targetName = transformation.schemaItems[reference]?.name
            {
                Text(targetName)
                    .foregroundColor(indentedSchemaItem.indentation == 1 ? .white : .gray)
            } else if let mapRule = cards[cardIndex].mapRules?[indentedSchemaItem.schemaItemId],
                      let subTransformationId = mapRule.subTransformationId
            {
                Text("\(subTransformationId)(...)")
            }
        }
    }

    var body: some View {
        let indentedSchemaItemList = updateIndentedSchemaItemList()
        if let subTransformationId = sharedState.subTransformationId
        {
            if let transformations = store.userDTO?.teams?["response"]?.transformations,
               let transformationId = sharedState.transformationId,
               let transformation = transformations[transformationId],
               let cards = cardType == "in" ? transformation.subTransformations[subTransformationId]?.inputs : transformation.subTransformations[subTransformationId]?.outputs
            {
                ZStack {
                    TopColorGradient(color: cardType == "in" ? .blue : .green)
                    if cardIndex < cards.count
                    {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                   
                                }) {
                                    Text("\(cardType) \(cardIndex)")
                                }.onDrag {
                                    sharedState.viewToDrop = ViewDropData(name: "YourDraggedData", cardType: cardType, cardIndex: cardIndex)
                                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                    return itemProvider
                                }
                                Button(action: {
                                    if let i = sharedState.viewStack.firstIndex(where: { aa in
                                        aa.cardIndex == cardIndex && aa.cardType == cardType
                                    }) {
                                        sharedState.viewStack.remove(at: i)
                                        openWindow(id: "SubTransformationView", value: MyData(intValue: cardIndex, stringValue: cardType))
                                    }
                                }) {
                                    Image(systemName: "lanyardcard")
                                }.clipShape(Circle())
                                if cardType == "out" {
                                    Button(action: {
                                        openWindow(id: "MapRuleEditor")
                                    }) {
                                        Image(systemName: "function")
                                    }
                                    .clipShape(Circle())
                                    Button(action: {
                                        openWindow(id: "FunctionCatalog")
                                    }) {
                                        Image(systemName: "list.bullet")
                                    }
                                    .clipShape(Circle())
                                }
                                Button(action: {
                                    openWindow(id: "CardSettingsView", value: CardSettingsData(intValue: cardIndex, stringValue: cardType))
                                }) {
                                    Image(systemName: "gear")
                                } .clipShape(Circle())
                            }.padding(.horizontal, 20)
                            List {
                                Section(header: Text("Schema Items")) {
                                    if let schemaItem = cards[cardIndex].schemaItemId,
                                       let schemaItemName = transformation.schemaItems[schemaItem]?.name {
                                        HStack {
                                            Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
                                            Spacer().frame(width: 20.0)
                                            Text(schemaItemName)
                                        }
                                    } else {
                                        Text("")
                                    }
                                    ForEach(indentedSchemaItemList) { indentedSchemaItem in
                                        Button(action: {
                                            if cardType == "out" && indentedSchemaItem.indentation == 1 {
                                                sharedState.cardType = cardType
                                                sharedState.cardIndex = cardIndex
                                                if sharedState.outputItemId == nil {
                                                    //openWindow(id: "MapRuleEditor")
                                                    //openWindow(id: "FunctionCatalog")
                                                    /*let mapRuleEditor = ViewDropData(name: "MapRuleEditor")
                                                    let functionCatalog = ViewDropData(name: "FunctionCatalog")
                                                    sharedState.viewStack.append(mapRuleEditor)
                                                    sharedState.viewStack.append(functionCatalog)*/
                                                }
                                                sharedState.outputItemId = indentedSchemaItem.schemaItemId
                                            } /*else if let outputItemId = sharedState.outputItemId,
                                                      let userDTO = store.userDTO
                                            {
                                                let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"]
                                                if var objectrule = cards[cardIndex].mapRules?[outputItemId]?.objectrule {
                                                    objectrule.reference = indentedSchemaItem.schemaItemId
                                                    let newUserDTO = updateClient(userDTO: userDTO, value: objectrule, keyPath: keyPath, operation: "setValue")
                                                    if let ret = newUserDTO {
                                                        store.userDTO = ret
                                                    }
                                                }
                                            }*/
                                        }) {
                                            if cardType == "in",
                                               indentedSchemaItem.indentation == 1
                                            {
                                                inputCardItem(for: indentedSchemaItem, transformation: transformation, cards: cards)
                                                .onDrag {
                                                    resetDragProperties()
                                                    if cardType == "in" {
                                                        sharedState.draggedSchemaItem = DraggedSchemaItem(schemaItemId: indentedSchemaItem.schemaItemId, rangeMax: indentedSchemaItem.rangeMax, numOfChildren: indentedSchemaItem.numOfChildren)
                                                    }
                                                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                                    return itemProvider
                                                }
                                            } else if cardType == "in" {
                                                inputCardItem(for: indentedSchemaItem, transformation: transformation, cards: cards)
                                            } else if let indentedInputItem = sharedState.draggedSchemaItem,
                                                      cardType == "out",
                                                      (indentedSchemaItem.rangeMax == indentedInputItem.rangeMax || indentedSchemaItem.rangeMax == "S"),
                                                      indentedSchemaItem.indentation == 1
                                            {
                                                outputCardItem(for: indentedSchemaItem, transformation: transformation, cards: cards)
                                                .onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                                    if let indentedInputItem = sharedState.draggedSchemaItem,
                                                       let userDTO = store.userDTO,
                                                       cardType == "out"
                                                    {
                                                        let _outputItemId = indentedSchemaItem.schemaItemId
                                                        let _inputSchemaItemId = indentedInputItem.schemaItemId
                                                        if indentedSchemaItem.rangeMax == "1" {
                                                            let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", _outputItemId, "objectrule"]
                                                            var objectrule: Expression
                                                            if var _objectrule = cards[cardIndex].mapRules?[_outputItemId]?.objectrule {
                                                                _objectrule.reference = indentedInputItem.schemaItemId
                                                                _objectrule.type = "reference"
                                                                objectrule = _objectrule
                                                            } else {
                                                                objectrule = Expression(type: "reference", reference: indentedInputItem.schemaItemId, rangeMax: indentedSchemaItem.rangeMax)
                                                            }
                                                            let jsonEncoder = JSONEncoder()
                                                            if let jsonData = try? jsonEncoder.encode(objectrule),
                                                               let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                                                store.send(.setValue(keyPath: keyPath, value: dictionary))
                                                                sharedState.draggedSchemaItem = nil
                                                            }
                                                        } else if indentedSchemaItem.rangeMax == "S" {
                                                            var newUserDTO: UserDTO?
                                                            if let subTransformationId = cards[cardIndex].mapRules?[indentedSchemaItem.schemaItemId]?.subTransformationId,
                                                               let inputCount = store.userDTO?.teams?["response"]?.transformations[transformationId]?.subTransformations[subTransformationId]?.inputs.count
                                                            {
                                                                let i = store.userDTO?.teams?["response"]?.transformations[transformationId]?.subTransformations[subTransformationId]?.inputs.firstIndex(where: { input in
                                                                    input.schemaItemId == _inputSchemaItemId
                                                                })
                                                                if let i = i
                                                                {

                                                                    let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "inputs", i]
                                                                    store.send(.removeKey(keyPath: keyPath))
                                                                } else {
                                                                    let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "inputs", inputCount]
                                                                    store.send(.setValue(keyPath: keyPath, value: ["schemaItemId": _inputSchemaItemId]))
                                                                }
                                                            } else {
                                                                let rand = randomAlphaNumeric(length: 4)
                                                                let value: [String: Any] = ["name": "f_\(rand)", "outputs": [["mapRules":[:], "schemaItemId": _outputItemId]], "inputs": [["schemaItemId": _inputSchemaItemId]]]
                                                                let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", "f_\(rand)"]
                                                                store.send(.setValue(keyPath: keyPath, value: value))
                                                                let keyPath2: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", _outputItemId, "subTransformationId"]
                                                                store.send(.setValue(keyPath: keyPath2, value: "f_\(rand)"))
                                                            }
                                                        }
                                                    }
                                                    sharedState.draggedSchemaItem = nil
                                                    return true
                                                }
                                            } else if cardType == "out"
                                            {
                                                outputCardItem(for: indentedSchemaItem, transformation: transformation, cards: cards)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

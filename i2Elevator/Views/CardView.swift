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
    let store: StoreOf<UserFeature>
    
    func updateIndentedSchemaItemList() -> [IndentedSchemaItem] {
        if let transformations = store.userDTO?.teams?["response"]?.transformations,
           let transformationId = sharedState.transformationId,
           let transformation = transformations[transformationId],
           let subTransformationId = sharedState.subTransformationId,
           let cards = cardType == "in" ? transformation.subTransformations[subTransformationId]?.inputs : transformation.subTransformations[subTransformationId]?.outputs,
           let userDTO = store.userDTO,
           cardIndex < cards.count,
           let schemaItemId = cards[cardIndex].schemaItemId,
           let schemaItem = store.userDTO?.teams?["response"]?.transformations[transformationId]?.schemaItems[schemaItemId]
        {
            var ret: [IndentedSchemaItem] = [IndentedSchemaItem(indentation: 0, numOfChildren: schemaItem.children.count, schemaItemId: schemaItemId, rangeMax: nil, numOf1SWalkedBy: 0, reference: [[schemaItemId]])]
            let a = transformSchemaEntityTreeToList(schemaItemId: cards[cardIndex].schemaItemId, userDTO: userDTO, transformationId: sharedState.transformationId, indentation: 1, numOf1SWalkedBy: 0, reference: [[]])
            ret.append(contentsOf: a)
            return ret
        } else {
            return []
        }
    }
    
    func isIndentedItemEnabled(indentedSchemaItem: IndentedSchemaItem, outputItemId: String?, subTransformation: SubTransformation?) -> Bool {
        if let subTransformation = subTransformation {
            if indentedSchemaItem.numOf1SWalkedBy < 1 {
                return true
            } else if let outputItemId = outputItemId {
                if let objectrule = subTransformation.outputs[0].mapRules?[outputItemId]?.objectrule,
                   objectrule.type == "function",
                   objectrule.function?.name == "LOOKUP",
                   indentedSchemaItem.numOf1SWalkedBy < 2
                {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    @ViewBuilder
    func inputCardItem(for indentedSchemaItem: IndentedSchemaItem, transformation: Transformation, cards: [Card], subTransformationId: String) -> some View {
        HStack {
            Spacer().frame(width: CGFloat(indentedSchemaItem.indentation) * 20.0)
            if indentedSchemaItem.numOfChildren == 0 {
                Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
            } else {
                Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
            }
            Spacer().frame(width: 20.0)
            if let schemaItem = transformation.schemaItems[indentedSchemaItem.schemaItemId] {
                if let rangeMax = indentedSchemaItem.rangeMax {
                    if isIndentedItemEnabled(indentedSchemaItem: indentedSchemaItem, outputItemId: sharedState.selectedSchemaItemId, subTransformation: transformation.subTransformations[subTransformationId])
                    {
                        if indentedSchemaItem.schemaItemId == sharedState.selectedSchemaItemId {
                            Text("\(schemaItem.name) 1:\(rangeMax)")
                                .foregroundColor(.white).bold()
                        } else {
                            Text("\(schemaItem.name) 1:\(rangeMax)")
                                .foregroundColor(.white)
                        }
                    } else {
                        if indentedSchemaItem.schemaItemId == sharedState.selectedSchemaItemId {
                            Text("\(schemaItem.name) 1:\(rangeMax)")
                                .foregroundColor(.gray).bold()
                        } else {
                            Text("\(schemaItem.name) 1:\(rangeMax)")
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    if isIndentedItemEnabled(indentedSchemaItem: indentedSchemaItem, outputItemId: sharedState.selectedSchemaItemId, subTransformation: transformation.subTransformations[subTransformationId])
                    {
                        if indentedSchemaItem.schemaItemId == sharedState.selectedSchemaItemId {
                            Text("\(schemaItem.name)")
                                .foregroundColor(.white).bold()
                        } else {
                            Text("\(schemaItem.name)")
                                .foregroundColor(.white)
                        }
                    } else {
                        if indentedSchemaItem.schemaItemId == sharedState.selectedSchemaItemId {
                            Text("\(schemaItem.name)")
                                .foregroundColor(.gray).bold()
                        } else {
                            Text("\(schemaItem.name)")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            Spacer()
            // NOTE: Maybe this never executed as it is input card, and no marule on inputcards?
            if let mapRule = cards[cardIndex].mapRules?[indentedSchemaItem.schemaItemId],
               let objectrule = mapRule.objectrule,
               let lastReference = objectrule.reference?.last?.last,
               objectrule.type == "reference",
               let targetName = transformation.schemaItems[lastReference]?.name
            {
                Text(targetName)
            }
        }
    }
    
    @ViewBuilder
    func outputCardItem(for indentedSchemaItem: IndentedSchemaItem, transformation: Transformation, cards: [Card], subTransformationId: String) -> some View {
        HStack {
            Spacer().frame(width: CGFloat(indentedSchemaItem.indentation) * 20.0)
            if indentedSchemaItem.numOfChildren == 0 {
                Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
            } else {
                Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
            }
            Spacer().frame(width: 20.0)
            if let schemaItem = transformation.schemaItems[indentedSchemaItem.schemaItemId] {
                if let rangeMax = indentedSchemaItem.rangeMax {
                    if isIndentedItemEnabled(indentedSchemaItem: indentedSchemaItem, outputItemId: sharedState.selectedSchemaItemId, subTransformation: transformation.subTransformations[subTransformationId])
                    {
                        Text("\(schemaItem.name) 1:\(rangeMax)")
                            .foregroundColor(.white)
                            .fontWeight(sharedState.selectedSchemaItemId == indentedSchemaItem.schemaItemId ? .bold : .regular)
                    } else {
                        Text("\(schemaItem.name) 1:\(rangeMax)")
                            .foregroundColor(.gray)
                            .fontWeight(sharedState.selectedSchemaItemId == indentedSchemaItem.schemaItemId ? .bold : .regular)
                    }
                } else {
                    if isIndentedItemEnabled(indentedSchemaItem: indentedSchemaItem, outputItemId: sharedState.selectedSchemaItemId, subTransformation: transformation.subTransformations[subTransformationId])
                    {
                        Text("\(schemaItem.name)")
                            .foregroundColor(.white)
                            .fontWeight(sharedState.selectedSchemaItemId == indentedSchemaItem.schemaItemId ? .bold : .regular)
                    } else {
                        Text("\(schemaItem.name)")
                            .foregroundColor(.gray)
                            .fontWeight(sharedState.selectedSchemaItemId == indentedSchemaItem.schemaItemId ? .bold : .regular)
                    }
                }
            }
            Spacer()
            if let mapRule = cards[cardIndex].mapRules?[indentedSchemaItem.schemaItemId],
               let objectrule = mapRule.objectrule,
               let lastReference = objectrule.reference?.last?.last,
               objectrule.type == "reference",
               let targetName = transformation.schemaItems[lastReference]?.name
            {
                if isIndentedItemEnabled(indentedSchemaItem: indentedSchemaItem, outputItemId: sharedState.selectedSchemaItemId, subTransformation: transformation.subTransformations[subTransformationId])
                {
                    Text(targetName)
                        .foregroundColor(.white)
                } else {
                    Text(targetName)
                        .foregroundColor(.gray)
                }
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
                if cardIndex < cards.count
                {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                if let i = sharedState.viewStack.firstIndex(where: { viewDropData in
                                    viewDropData.cardIndex == cardIndex && viewDropData.cardType == cardType
                                }) {
                                    sharedState.viewStack.remove(at: i)
                                }
                            }) {
                                Image(systemName: "multiply.circle")
                            }
                            Button(action: {
                            }) {
                                Text("\(cardType) \(cardIndex)")
                            }.onDrag {
                                sharedState.viewToDrop = ViewDropData(name: "YourDraggedData", cardType: cardType, cardIndex: cardIndex)
                                let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                return itemProvider
                            }
                        }.padding(.horizontal, 20)
                        List {
                            ForEach(indentedSchemaItemList) { indentedSchemaItem in
                                Button(action: {
                                    if cardType == "out" && (indentedSchemaItem.numOf1SWalkedBy < 1) {
                                        sharedState.cardType = cardType
                                        sharedState.cardIndex = cardIndex
                                        sharedState.selectedSchemaItemId = indentedSchemaItem.schemaItemId
                                    }
                                }) {
                                    if cardType == "in",
                                       isIndentedItemEnabled(indentedSchemaItem: indentedSchemaItem, outputItemId: sharedState.selectedSchemaItemId, subTransformation: transformation.subTransformations[subTransformationId]) == true
                                    {
                                        inputCardItem(for: indentedSchemaItem, transformation: transformation, cards: cards, subTransformationId: subTransformationId)
                                            .onDrag {
                                                resetDragProperties()
                                                if cardType == "in" {
                                                    sharedState.draggedSchemaItem = DraggedSchemaItem(schemaItemId: indentedSchemaItem.schemaItemId, rangeMax: indentedSchemaItem.rangeMax, numOfChildren: indentedSchemaItem.numOfChildren, reference: indentedSchemaItem.reference)
                                                }
                                                let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                                return itemProvider
                                            }
                                            .onTapGesture {
                                                sharedState.selectedSchemaItemId = indentedSchemaItem.schemaItemId
                                            }
                                    } else if cardType == "in" {
                                        inputCardItem(for: indentedSchemaItem, transformation: transformation, cards: cards, subTransformationId: subTransformationId)
                                            .onTapGesture {
                                                sharedState.selectedSchemaItemId = indentedSchemaItem.schemaItemId
                                            }
                                    } else if let _ = sharedState.draggedSchemaItem,
                                              cardType == "out",
                                              isIndentedItemEnabled(indentedSchemaItem: indentedSchemaItem, outputItemId: sharedState.selectedSchemaItemId, subTransformation: transformation.subTransformations[subTransformationId]) == true
                                    {
                                        outputCardItem(for: indentedSchemaItem, transformation: transformation, cards: cards, subTransformationId: subTransformationId)
                                            .onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                                if let indentedInputItem = sharedState.draggedSchemaItem,
                                                   cardType == "out"
                                                {
                                                    let _outputItemId = indentedSchemaItem.schemaItemId
                                                    let _inputSchemaItemId = indentedInputItem.schemaItemId
                                                    if indentedSchemaItem.rangeMax == "S" {
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
                                                    } else { // "1" and nil
                                                        let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", _outputItemId, "objectrule"]
                                                        var objectrule: Expression
                                                        if var _objectrule = cards[cardIndex].mapRules?[_outputItemId]?.objectrule {
                                                            _objectrule.reference = indentedInputItem.reference
                                                            _objectrule.type = "reference"
                                                            objectrule = _objectrule
                                                        } else {
                                                            objectrule = Expression(type: "reference", reference: indentedInputItem.reference, rangeMax: indentedSchemaItem.rangeMax)
                                                        }
                                                        let jsonEncoder = JSONEncoder()
                                                        if let jsonData = try? jsonEncoder.encode(objectrule),
                                                           let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                                            store.send(.setValue(keyPath: keyPath, value: dictionary))
                                                            sharedState.draggedSchemaItem = nil
                                                        }
                                                    }
                                                }
                                                sharedState.draggedSchemaItem = nil
                                                return true
                                            }
                                    } else if cardType == "out"
                                    {
                                        outputCardItem(for: indentedSchemaItem, transformation: transformation, cards: cards, subTransformationId: subTransformationId)
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

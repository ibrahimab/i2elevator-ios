//
//  CardContentView.swift
//  i2Elevator
//
//  Created by János Kukoda on 01/08/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture

struct CardContentView: View {
    var cardType: String
    var cardIndex: Int
    @EnvironmentObject var sharedState: SharedState
    let store: StoreOf<UserFeature>
    var transformation: Transformation
    var cards: [Card]
    var subTransformationId: String
    
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
            let a = transformSchemaEntityTreeToList(schemaItemId: cards[cardIndex].schemaItemId, userDTO: userDTO, shareState: sharedState, transformationId: sharedState.transformationId, indentation: 1, numOf1SWalkedBy: 0, reference: [[]])
            ret.append(contentsOf: a)
            return ret
        } else {
            return []
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
            if let rightText = indentedSchemaItem.rightText {
                Text(rightText)
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
    
    func isIndentedItemEnabled(indentedSchemaItem: IndentedSchemaItem, outputItemId: String?, subTransformation: SubTransformation?) -> Bool {
        if let subTransformation = subTransformation {
            if indentedSchemaItem.numOf1SWalkedBy < 100 { // TODO: Change it later, maybe to 1
                return true
            } else if let outputItemId = outputItemId {
                if let objectrule = subTransformation.outputs[0].mapRules?[outputItemId]?.objectrule,
                   objectrule.type == "function",
                   (objectrule.function?.name == "LOOKUP" || objectrule.function?.name == "GROUP"),
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

    var body: some View {
        Group {
            let indentedSchemaItemList = updateIndentedSchemaItemList()
            ForEach(indentedSchemaItemList, id: \.schemaItemId) { indentedSchemaItem in
                Button(action: {
                    if cardType == "out" /*&& (indentedSchemaItem.numOf1SWalkedBy < 1)*/ {
                        sharedState.cardType = cardType
                        sharedState.cardIndex = cardIndex
                        sharedState.selectedSchemaItemId = indentedSchemaItem.schemaItemId
                        sharedState.selectedParentSchemaItemId = indentedSchemaItem.parentSchemaItemId
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
                                sharedState.selectedParentSchemaItemId = indentedSchemaItem.parentSchemaItemId
                            }
                    } else if cardType == "in" {
                        inputCardItem(for: indentedSchemaItem, transformation: transformation, cards: cards, subTransformationId: subTransformationId)
                            .onTapGesture {
                                sharedState.selectedSchemaItemId = indentedSchemaItem.schemaItemId
                                sharedState.selectedParentSchemaItemId = indentedSchemaItem.parentSchemaItemId
                            }
                    } else if let _ = sharedState.draggedSchemaItem,
                              cardType == "out",
                              isIndentedItemEnabled(indentedSchemaItem: indentedSchemaItem, outputItemId: sharedState.selectedSchemaItemId, subTransformation: transformation.subTransformations[subTransformationId]) == true
                    {
                        outputCardItem(for: indentedSchemaItem, transformation: transformation, cards: cards, subTransformationId: subTransformationId)
                            .onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                // Existing onDrop implementation
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


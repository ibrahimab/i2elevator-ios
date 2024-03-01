//
//  CardView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct CardView: View {
    var cardIndex: Int
    var cardType: String
    @EnvironmentObject var sharedState: SharedState
    var body: some View {
        if let subTransformationId = sharedState.subTransformationId
        {
            if let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
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
                            Text("\(cardType) \(cardIndex) \(cards[cardIndex].name)")
                            List {
                                /*Section(header: Text("Root")) {
                                 HStack {
                                 Text("json-abcd")
                                 Spacer()
                                 Image(systemName: "chevron.right")
                                 }
                                 }*/
                                Section(header: Text("Schema Items")) {
                                    ForEach(cards[cardIndex].indentedSchemaItems.indices, id: \.self) { index in
                                        Button(action: {
                                            if cardType == "out" {
                                                sharedState.outputItemId = cards[cardIndex].indentedSchemaItems[index].schemaItemId
                                            } else if let outputItemId = sharedState.outputItemId,
                                                      let userDTO = sharedState.userDTO
                                            {
                                                let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId]
                                                let newUserDTO = updateClient(userDTO: userDTO, value: cards[cardIndex].indentedSchemaItems[index].schemaItemId, keyPath: keyPath, operation: "setValue")
                                                if let ret = newUserDTO {
                                                    sharedState.userDTO = ret
                                                }
                                            }
                                        }) {
                                            if cardType == "in" {
                                                HStack {
                                                    Spacer().frame(width: CGFloat((cards[cardIndex].indentedSchemaItems[index].indentation + 1)) * 20.0)
                                                    if cards[cardIndex].indentedSchemaItems[index].type == "leaf" {
                                                        Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
                                                    } else {
                                                        Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
                                                    }
                                                    Spacer().frame(width: 20.0)
                                                    if let schemaItem = transformation.schemaItems[cards[cardIndex].indentedSchemaItems[index].schemaItemId] {
                                                        Text("\(schemaItem.name) 1:\(cards[cardIndex].indentedSchemaItems[index].rangeMax)").fontWeight((cardType == "out" && sharedState.outputItemId == cards[cardIndex].indentedSchemaItems[index].schemaItemId) ? .bold : .regular)
                                                    }
                                                    Spacer()
                                                    if let targetId = cards[cardIndex].mapRules[cards[cardIndex].indentedSchemaItems[index].schemaItemId],
                                                       let targetName = transformation.schemaItems[targetId]?.name
                                                    {
                                                        Text(targetName)
                                                    }
                                                }
                                                .onDrag {
                                                    if cardType == "in" {
                                                        sharedState.inputIndentedSchemaItemId = index
                                                        
                                                        //cards[cardIndex].indentedSchemaItems[index].schemaItemId
                                                    }
                                                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                                    return itemProvider
                                                }
                                            } else if let inputIndentedSchemaItemId = sharedState.inputIndentedSchemaItemId,
                                                      cardType == "out" && cards[cardIndex].indentedSchemaItems[index].rangeMax == cards[cardIndex].indentedSchemaItems[inputIndentedSchemaItemId].rangeMax
                                            {
                                                HStack {
                                                    Spacer().frame(width: CGFloat((cards[cardIndex].indentedSchemaItems[index].indentation + 1)) * 20.0)
                                                    if cards[cardIndex].indentedSchemaItems[index].type == "leaf" {
                                                        Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
                                                    } else {
                                                        Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
                                                    }
                                                    Spacer().frame(width: 20.0)
                                                    if let schemaItem = transformation.schemaItems[cards[cardIndex].indentedSchemaItems[index].schemaItemId] {
                                                        Text("\(schemaItem.name) 1:\(cards[cardIndex].indentedSchemaItems[index].rangeMax)").fontWeight((cardType == "out" && sharedState.outputItemId == cards[cardIndex].indentedSchemaItems[index].schemaItemId) ? .bold : .regular)
                                                    }
                                                    Spacer()
                                                    if let targetId = cards[cardIndex].mapRules[cards[cardIndex].indentedSchemaItems[index].schemaItemId],
                                                       let targetName = transformation.schemaItems[targetId]?.name
                                                    {
                                                        Text(targetName)
                                                    }
                                                }
                                                .onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                                    if let inputIndentedSchemaItemId = sharedState.inputIndentedSchemaItemId,
                                                       let userDTO = sharedState.userDTO,
                                                       cardType == "out"
                                                    {
                                                        let _outputItemId = cards[cardIndex].indentedSchemaItems[index].schemaItemId
                                                        let inputItemSchemaId = cards[cardIndex].indentedSchemaItems[inputIndentedSchemaItemId].schemaItemId
                                                        let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", _outputItemId]
                                                        let newUserDTO = updateClient(userDTO: userDTO, value: inputItemSchemaId, keyPath: keyPath, operation: "setValue")
                                                        if let newUserDTO = newUserDTO {
                                                            sharedState.userDTO = newUserDTO
                                                        }
                                                    }
                                                    return true
                                                }
                                            } else if cardType == "out"
                                            {
                                                HStack {
                                                    Spacer().frame(width: CGFloat((cards[cardIndex].indentedSchemaItems[index].indentation + 1)) * 20.0)
                                                    if cards[cardIndex].indentedSchemaItems[index].type == "leaf" {
                                                        Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
                                                    } else {
                                                        Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
                                                    }
                                                    Spacer().frame(width: 20.0)
                                                    if let schemaItem = transformation.schemaItems[cards[cardIndex].indentedSchemaItems[index].schemaItemId] {
                                                        Text("\(schemaItem.name) 1:\(cards[cardIndex].indentedSchemaItems[index].rangeMax)").fontWeight((cardType == "out" && sharedState.outputItemId == cards[cardIndex].indentedSchemaItems[index].schemaItemId) ? .bold : .regular)
                                                    }
                                                    Spacer()
                                                    if let targetId = cards[cardIndex].mapRules[cards[cardIndex].indentedSchemaItems[index].schemaItemId],
                                                       let targetName = transformation.schemaItems[targetId]?.name
                                                    {
                                                        Text(targetName)
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
    }
}

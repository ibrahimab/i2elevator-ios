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
    @Environment(\.openWindow) private var openWindow
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
                            Text("\(cardType) \(cardIndex))")
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
                                                sharedState.cardType = cardType
                                                sharedState.cardIndex = cardIndex
                                                if sharedState.outputItemId == nil {
                                                    openWindow(id: "MapRuleEditor")
                                                }
                                                sharedState.outputItemId = cards[cardIndex].indentedSchemaItems[index].schemaItemId
                                            } else if let outputItemId = sharedState.outputItemId,
                                                      let userDTO = sharedState.userDTO
                                            {
                                                let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"]
                                                if var objectrule = cards[cardIndex].mapRules?[outputItemId]?.objectrule {
                                                    objectrule.reference = cards[cardIndex].indentedSchemaItems[index].schemaItemId
                                                    let newUserDTO = updateClient(userDTO: userDTO, value: objectrule, keyPath: keyPath, operation: "setValue")
                                                    if let ret = newUserDTO {
                                                        sharedState.userDTO = ret
                                                    }
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
                                                    if let mapRule = cards[cardIndex].mapRules?[cards[cardIndex].indentedSchemaItems[index].schemaItemId],
                                                       let objectrule = mapRule.objectrule,
                                                       let reference = objectrule.reference,
                                                       objectrule.type == "reference",
                                                       let targetName = transformation.schemaItems[reference]?.name
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
                                                    if let mapRule = cards[cardIndex].mapRules?[cards[cardIndex].indentedSchemaItems[index].schemaItemId],
                                                       let objectrule = mapRule.objectrule,
                                                       let reference = objectrule.reference,
                                                       objectrule.type == "reference",
                                                       let targetName = transformation.schemaItems[reference]?.name
                                                    {
                                                        Text(targetName)
                                                    } else if let mapRule = cards[cardIndex].mapRules?[cards[cardIndex].indentedSchemaItems[index].schemaItemId],
                                                              let subTransformationId = mapRule.subTransformationId
                                                    {
                                                        Text("\(subTransformationId)(...)")
                                                    }
                                                }
                                                .onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                                    if let inputIndentedSchemaItemId = sharedState.inputIndentedSchemaItemId,
                                                       let userDTO = sharedState.userDTO,
                                                       cardType == "out"
                                                    {
                                                        let _outputItemId = cards[cardIndex].indentedSchemaItems[index].schemaItemId
                                                        let _inputSchemaItemId = cards[cardIndex].indentedSchemaItems[inputIndentedSchemaItemId].schemaItemId
                                                        if cards[cardIndex].indentedSchemaItems[index].rangeMax == "1" {
                                                            let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", _outputItemId, "objectrule"]
                                                            var objectrule: Expression
                                                            if var _objectrule = cards[cardIndex].mapRules?[_outputItemId]?.objectrule {
                                                                _objectrule.reference = cards[cardIndex].indentedSchemaItems[inputIndentedSchemaItemId].schemaItemId
                                                                _objectrule.type = "reference"
                                                                objectrule = _objectrule
                                                            } else {
                                                                objectrule = Expression(reference: cards[cardIndex].indentedSchemaItems[inputIndentedSchemaItemId].schemaItemId, type: "reference")
                                                            }
                                                            let jsonEncoder = JSONEncoder()
                                                            if let jsonData = try? jsonEncoder.encode(objectrule),
                                                               let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                                                let newUserDTO = updateClient(userDTO: userDTO, value: dictionary, keyPath: keyPath, operation: "setValue")
                                                                if let ret = newUserDTO {
                                                                    sharedState.userDTO = ret
                                                                    sharedState.inputIndentedSchemaItemId = nil
                                                                }
                                                            }
                                                        } else if cards[cardIndex].indentedSchemaItems[index].rangeMax == "S" {
                                                            let rand = randomAlphaNumeric(length: 4)
                                                            let value: [String: Any] = ["name": "f_\(rand)", "outputs": [["mapRules":[:], "schemaItemId": _outputItemId, "indentedSchemaItems": []]], "inputs": [["schemaItemId": _inputSchemaItemId, "indentedSchemaItems": []]]]
                                                            let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", "f_\(rand)"]
                                                            let newUserDTO = updateClient(userDTO: userDTO, value: value, keyPath: keyPath, operation: "setValue")
                                                            let keyPath2: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", _outputItemId, "subTransformationId"]
                                                            if let newUserDTO = newUserDTO {
                                                                let newUserDTO2 = updateClient(userDTO: newUserDTO, value: "f_\(rand)", keyPath: keyPath2, operation: "setValue")
                                                                if let newUserDTO = newUserDTO2 {
                                                                    sharedState.userDTO = newUserDTO
                                                                    sharedState.inputIndentedSchemaItemId = nil
                                                                }
                                                            }
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
                                                    if let mapRule = cards[cardIndex].mapRules?[cards[cardIndex].indentedSchemaItems[index].schemaItemId],
                                                       let objectrule = mapRule.objectrule,
                                                       let reference = objectrule.reference,
                                                       objectrule.type == "reference",
                                                       let targetName = transformation.schemaItems[reference]?.name
                                                    {
                                                        Text(targetName)
                                                    } else if let mapRule = cards[cardIndex].mapRules?[cards[cardIndex].indentedSchemaItems[index].schemaItemId],
                                                              let subTransformationId = mapRule.subTransformationId
                                                    {
                                                        Text("\(subTransformationId)(...)")
                                                    }
                                                }
                                            }
                                        }                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

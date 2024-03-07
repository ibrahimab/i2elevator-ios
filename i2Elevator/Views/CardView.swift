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

    func updateIndentedSchemaItemList() -> [IndentedSchemaItem] {
        if let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
           let transformationId = sharedState.transformationId,
           let transformation = transformations[transformationId],
           let subTransformationId = sharedState.subTransformationId,
           let cards = cardType == "in" ? transformation.subTransformations[subTransformationId]?.inputs : transformation.subTransformations[subTransformationId]?.outputs,
           let userDTO = sharedState.userDTO
        {
            let a = transformSchemaEntityTreeToList(schemaItemId: cards[cardIndex].schemaItemId, userDTO: userDTO, transformationId: sharedState.transformationId, indentation: 0)
            return a
        } else {
            return []
        }
    }
    
    var body: some View {
        let indentedSchemaItemList = updateIndentedSchemaItemList()
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
                            Text("\(cardType) \(cardIndex)")
                            List {
                                Section(header: Text("Root")) {
                                    HStack {
                                        if let schemaItem = cards[cardIndex].schemaItemId,
                                           let schemaItemName = transformation.schemaItems[schemaItem]?.name {
                                            Text(schemaItemName)
                                        } else {
                                            Text("")
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                Section(header: Text("Schema Items")) {
                                    ForEach(indentedSchemaItemList) { indentedSchemaItem in
                                        Button(action: {
                                            if cardType == "out" {
                                                sharedState.cardType = cardType
                                                sharedState.cardIndex = cardIndex
                                                if sharedState.outputItemId == nil {
                                                    openWindow(id: "MapRuleEditor")
                                                    openWindow(id: "FunctionCatalog")
                                                }
                                                sharedState.outputItemId = indentedSchemaItem.schemaItemId
                                            } else if let outputItemId = sharedState.outputItemId,
                                                      let userDTO = sharedState.userDTO
                                            {
                                                let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"]
                                                if var objectrule = cards[cardIndex].mapRules?[outputItemId]?.objectrule {
                                                    objectrule.reference = indentedSchemaItem.schemaItemId
                                                    let newUserDTO = updateClient(userDTO: userDTO, value: objectrule, keyPath: keyPath, operation: "setValue")
                                                    if let ret = newUserDTO {
                                                        sharedState.userDTO = ret
                                                    }
                                                }
                                            }
                                        }) {
                                            if cardType == "in" {
                                                HStack {
                                                    Spacer().frame(width: CGFloat(indentedSchemaItem.indentation + 1) * 20.0)
                                                    if indentedSchemaItem.type == "leaf" {
                                                        Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
                                                    } else {
                                                        Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
                                                    }
                                                    Spacer().frame(width: 20.0)
                                                    if let schemaItem = transformation.schemaItems[indentedSchemaItem.schemaItemId] {
                                                        Text("\(schemaItem.name) 1:\(indentedSchemaItem.rangeMax)").fontWeight((cardType == "out" && sharedState.outputItemId == indentedSchemaItem.schemaItemId) ? .bold : .regular)
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
                                                .onDrag {
                                                    if cardType == "in" {
                                                        sharedState.indentedInputItem = indentedSchemaItem
                                                    }
                                                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                                    return itemProvider
                                                }
                                            } else if let indentedInputItem = sharedState.indentedInputItem,
                                                      cardType == "out" && indentedSchemaItem.rangeMax == indentedInputItem.rangeMax
                                            {
                                                HStack {
                                                    Spacer().frame(width: CGFloat((indentedSchemaItem.indentation + 1)) * 20.0)
                                                    if indentedInputItem.type == "leaf" {
                                                        Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
                                                    } else {
                                                        Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
                                                    }
                                                    Spacer().frame(width: 20.0)
                                                    if let schemaItem = transformation.schemaItems[indentedSchemaItem.schemaItemId] {
                                                        Text("\(schemaItem.name) 1:\(indentedSchemaItem.rangeMax)").fontWeight((cardType == "out" && sharedState.outputItemId == indentedSchemaItem.schemaItemId) ? .bold : .regular)
                                                    }
                                                    Spacer()
                                                    if let mapRule = cards[cardIndex].mapRules?[indentedSchemaItem.schemaItemId],
                                                       let objectrule = mapRule.objectrule,
                                                       let reference = objectrule.reference,
                                                       objectrule.type == "reference",
                                                       let targetName = transformation.schemaItems[reference]?.name
                                                    {
                                                        Text(targetName)
                                                    } else if let mapRule = cards[cardIndex].mapRules?[indentedSchemaItem.schemaItemId],
                                                              let subTransformationId = mapRule.subTransformationId
                                                    {
                                                        Text("\(subTransformationId)(...)")
                                                    }
                                                }
                                                .onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                                                    if let indentedInputItem = sharedState.indentedInputItem,
                                                       let userDTO = sharedState.userDTO,
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
                                                                objectrule = Expression(reference: indentedInputItem.schemaItemId, type: "reference")
                                                            }
                                                            let jsonEncoder = JSONEncoder()
                                                            if let jsonData = try? jsonEncoder.encode(objectrule),
                                                               let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                                                let newUserDTO = updateClient(userDTO: userDTO, value: dictionary, keyPath: keyPath, operation: "setValue")
                                                                if let ret = newUserDTO {
                                                                    sharedState.userDTO = ret
                                                                    sharedState.indentedInputItem = nil
                                                                }
                                                            }
                                                        } else if indentedSchemaItem.rangeMax == "S" {
                                                            let rand = randomAlphaNumeric(length: 4)
                                                            let value: [String: Any] = ["name": "f_\(rand)", "outputs": [["mapRules":[:], "schemaItemId": _outputItemId, "indentedSchemaItems": []]], "inputs": [["schemaItemId": _inputSchemaItemId, "indentedSchemaItems": []]]]
                                                            let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", "f_\(rand)"]
                                                            let newUserDTO = updateClient(userDTO: userDTO, value: value, keyPath: keyPath, operation: "setValue")
                                                            let keyPath2: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", _outputItemId, "subTransformationId"]
                                                            if let newUserDTO = newUserDTO {
                                                                let newUserDTO2 = updateClient(userDTO: newUserDTO, value: "f_\(rand)", keyPath: keyPath2, operation: "setValue")
                                                                if let newUserDTO = newUserDTO2 {
                                                                    sharedState.userDTO = newUserDTO
                                                                    sharedState.indentedInputItem = nil
                                                                }
                                                            }
                                                        }
                                                    }
                                                    return true
                                                }
                                            } else if cardType == "out"
                                            {
                                                HStack {
                                                    Spacer().frame(width: CGFloat((indentedSchemaItem.indentation + 1)) * 20.0)
                                                    if indentedSchemaItem.type == "leaf" {
                                                        Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
                                                    } else {
                                                        Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
                                                    }
                                                    Spacer().frame(width: 20.0)
                                                    if let schemaItem = transformation.schemaItems[indentedSchemaItem.schemaItemId] {
                                                        Text("\(schemaItem.name) 1:\(indentedSchemaItem.rangeMax)").fontWeight((cardType == "out" && sharedState.outputItemId == indentedSchemaItem.schemaItemId) ? .bold : .regular)
                                                    }
                                                    Spacer()
                                                    if let mapRule = cards[cardIndex].mapRules?[indentedSchemaItem.schemaItemId],
                                                       let objectrule = mapRule.objectrule,
                                                       let reference = objectrule.reference,
                                                       objectrule.type == "reference",
                                                       let targetName = transformation.schemaItems[reference]?.name
                                                    {
                                                        Text(targetName)
                                                    } else if let mapRule = cards[cardIndex].mapRules?[indentedSchemaItem.schemaItemId],
                                                              let subTransformationId = mapRule.subTransformationId
                                                    {
                                                        Text("\(subTransformationId)(...)")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.onAppear {
                    self.updateIndentedSchemaItemList()
                }
            }
        }
    }
}

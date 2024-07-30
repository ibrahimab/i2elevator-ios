//
//  GenerateIndentedSchemaItemList.swift
//  i2Elevator
//
//  Created by János Kukoda on 01/08/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture


func generateIndentedSchemaItemList(
    cardIndex: Int,
    cardType: String,
    sharedState: SharedState,
    store: StoreOf<UserFeature>
) -> [IndentedSchemaItem] {
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

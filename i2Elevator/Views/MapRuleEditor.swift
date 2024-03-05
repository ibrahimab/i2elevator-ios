//
//  MapRuleEditor.swift
//  i2Elevator
//
//  Created by János Kukoda on 05/03/2024.
//

import SwiftUI

struct MapRuleEditor: View {
    @EnvironmentObject var sharedState: SharedState
    var body: some View {
        ZStack {
            TopColorGradient(color: .yellow)
            if let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
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
                if mapRule.objectrule?.type == "reference",
                   let reference = mapRule.objectrule?.reference,
                   let schemaItemName = transformation.schemaItems[reference]?.name
                {
                    Text("=\(schemaItemName)")
                        .padding()
                } else if let subTransformationId = mapRule.subTransformationId
                {
                    Text("=\(subTransformationId)(...)")
                }
            }
        }
    }
}

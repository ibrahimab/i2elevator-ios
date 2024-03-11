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
                }
                .padding(.bottom, 40)
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
                    let expressionGrid = transformMapRuleToGrid(mapRule: mapRule, schemaItems: transformation.schemaItems, rowInd: &rowInd, transformation: transformation)
                    ForEach(expressionGrid, id: \.rowInd) { v in
                        HStack {
                            Spacer().frame(width: CGFloat(v.indentation) * 20.0)
                            ForEach(v.columns, id: \.index) { v2 in
                                if v2.isBtnStyle == true {
                                    //let b = compareArrays(expressionKeypathSegment, v2.expressionKeypathSegment)
                                    Button(action: {
                                        /*expressionKeypathSegment = v2.expressionKeypathSegment
                                         expressionColumn = v2
                                         inputSchemaItemId = nil*/
                                    }) {
                                        Text(v2.text)
                                            .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                            .foregroundColor(.white)
                                        //.background(b ? Color.green : Color.blue)
                                            .cornerRadius(8)
                                    }
                                } else {
                                    Text(v2.text)
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

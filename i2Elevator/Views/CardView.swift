//
//  CardView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI

struct CardView: View {
    var cardIndex: Int
    var cardType: String
    @EnvironmentObject var sharedState: SharedState
    var body: some View {
        if let subTransformationId = sharedState.subTransformationId
        {
            if let transformationId = sharedState.transformationId,
               let subTransformations = transformations[transformationId]?.subTransformations,
               let cards = cardType == "in" ? subTransformations[subTransformationId]?.cardsIn : subTransformations[subTransformationId]?.cardsOut
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
                                        HStack {
                                            Spacer().frame(width: CGFloat((cards[cardIndex].indentedSchemaItems[index].indentation)) * 20.0)
                                            if cards[cardIndex].indentedSchemaItems[index].type == "leaf" {
                                                Image(systemName: "triangle.fill").frame(width: 8, height: 8).foregroundColor(Color.green)
                                            } else {
                                                Image(systemName: "circle.fill").frame(width: 8, height: 8).foregroundColor(Color.blue)
                                            }
                                            Spacer().frame(width: 20.0)
                                            Text(cards[cardIndex].indentedSchemaItems[index].schemaItemName)
                                            Spacer()
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

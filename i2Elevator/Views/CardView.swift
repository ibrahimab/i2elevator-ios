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
            if let cc = cardType == "in" ? subTransformations[subTransformationId]?.cardsIn : subTransformations[subTransformationId]?.cardsOut {
                if cardIndex < cc.count
                {
                    Spacer()
                    Text("\(cardType) \(cardIndex) \(cc[cardIndex].name)")
                    List {
                        Section(header: Text("Root")) {
                            HStack {
                                Text("json-abcd")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        Section(header: Text("Schema Items")) {
                            ForEach(cc[cardIndex].indentedSchemaItems.indices, id: \.self) { index in
                                HStack {
                                    Spacer().frame(width: CGFloat((cc[cardIndex].indentedSchemaItems[index].indentation)) * 20.0)
                                    Text(cc[cardIndex].indentedSchemaItems[index].schemaItemName)
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

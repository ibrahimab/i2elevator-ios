//
//  CardContainerView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture

struct CardContainerView: View {
    var cardIndex: Int
    var cardType: String
    @EnvironmentObject var sharedState: SharedState
    let store: StoreOf<UserFeature>
    
    var body: some View {
            if let subTransformationId = sharedState.subTransformationId,
               let transformations = store.userDTO?.teams?["response"]?.transformations,
               let transformationId = sharedState.transformationId,
               let transformation = transformations[transformationId],
               let cards = cardType == "in" ? transformation.subTransformations[subTransformationId]?.inputs : transformation.subTransformations[subTransformationId]?.outputs,
               cardIndex < cards.count
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
                        CardContentView(cardType: cardType, cardIndex: cardIndex, store: store, transformation: transformation, cards: cards, subTransformationId: subTransformationId)
                    }
                }
            }
        }
}

//
//  CardView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture

struct CardSettingsView: View {
    var cardIndex: Int
    var cardType: String
    @State private var isSelectionListVisible: Bool = false
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.openWindow) private var openWindow
    let store: StoreOf<UserFeature>

    var body: some View {
        if let subTransformationId = sharedState.subTransformationId
        {
            if let transformations = store.userDTO?.teams?["response"]?.transformations,
               let transformationId = sharedState.transformationId,
               let transformation = transformations[transformationId],
               let cards = cardType == "in" ? transformation.subTransformations[subTransformationId]?.inputs : transformation.subTransformations[subTransformationId]?.outputs
            {
                ZStack {
                    TopColorGradient(color: .indigo)
                    if cardIndex < cards.count
                    {
                        VStack {
                            Spacer()
                            List {
                                Section(header: Text("Root")) {
                                    if let userDTO = store.userDTO,
                                       isSelectionListVisible == true {
                                        ForEach(Array(transformation.schemaItems.keys.sorted()), id: \.self) { schemaItemId in
                                            Button(action: {
                                                let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, cardType == "in" ? "inputs" : "outputs", cardIndex, "schemaItemId"]
                                                store.send(.setValue(keyPath: keyPath, value: schemaItemId))
                                                self.isSelectionListVisible = false
                                            }) {
                                                HStack {
                                                    if let schemaItemName = transformation.schemaItems[schemaItemId]?.name {
                                                        Text(schemaItemName)
                                                    } else {
                                                        Text("")
                                                    }
                                                    Spacer()
                                                    if cards[cardIndex].schemaItemId == schemaItemId {
                                                        Image(systemName: "circle.fill")
                                                    } else {
                                                        Image(systemName: "circle")
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        Button(action: {
                                            self.isSelectionListVisible = true
                                        }) {
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
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 40)
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}

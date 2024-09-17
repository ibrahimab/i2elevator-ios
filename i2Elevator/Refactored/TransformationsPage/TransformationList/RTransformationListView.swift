//
//  TransformationListView.swift
//  i2Elevator
//

import SwiftUI
import ComposableArchitecture

struct RTransformationListView: View {
    let store: StoreOf<RTransformationListFeature>
    var body: some View {

        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
            ForEach(store.transformations) { transformation in
                RTransformationListItemView(transformation: transformation)
            }
        }
        .padding()
    }
}

#Preview("[TransformationListView] without tags provided") {
    RTransformationListView(
        store: Store(
            initialState: RTransformationListFeature.State(
                transformations: [
                    RTransformation(id: UUID(), name: "User Journey"),
                    RTransformation(id: UUID(), name: "AirBnb Importer"),
                    RTransformation(id: UUID(), name: "Group Example"),
                    RTransformation(id: UUID(), name: "Field pass down"),
                    RTransformation(id: UUID(), name: "Container Example"),
                    RTransformation(id: UUID(), name: "Color Group Example"),
                    RTransformation(id: UUID(), name: "Item Saleable v2")
                ]
            )
        ) {
            RTransformationListFeature()
        }
    )
}


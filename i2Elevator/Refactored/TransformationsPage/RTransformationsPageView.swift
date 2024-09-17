//
//  TransformationsPageView.swift
//  i2Elevator
//
import SwiftUI
import ComposableArchitecture

struct RTransformationsPageView: View {
    let store: StoreOf<RTransformationListFeature>
    var body: some View {
        VStack {
            RCreateTransformationButtonView()
            RTransformationListView(store: store)
        }
        .padding()
    }
}

#Preview("[TransformationsPageView] page of list of transformations and create button") {
    RTransformationsPageView(
        store: Store(initialState: RTransformationListFeature.State(
            transformations: [
                RTransformation(id: UUID(), name: "User Journey"),
                RTransformation(id: UUID(), name: "AirBnb Importer"),
                RTransformation(id: UUID(), name: "Group Example"),
                RTransformation(id: UUID(), name: "Field pass down"),
                RTransformation(id: UUID(), name: "Container Example"),
                RTransformation(id: UUID(), name: "Color Group Example"),
                RTransformation(id: UUID(), name: "Item Saleable v2")
            ]
        )) {
        RTransformationListFeature()
    })
}

//
//  TransformationListView.swift
//  i2Elevator
//
//  Created by János Kukoda on 30/07/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture

struct TransformationListView: View {
    let store: StoreOf<UserFeature>
    @EnvironmentObject var sharedState: SharedState
    let geometry: GeometryProxy
    
    var body: some View {
        if let transformations = store.userDTO?.teams?["response"]?.transformations
        {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        let transformationId = randomAlphaNumeric(length: 4)
                        let outputRootItemId = randomAlphaNumeric(length: 4)
                        let inputRootItemId = randomAlphaNumeric(length: 4)
                        let value: [String: Any] = ["name": "New transformation",
                                                    "subTransformations": [
                                                        transformationId: ["name": "New sub transformation",
                                                                           "outputs": [["mapRules":[:],
                                                                                        "schemaItemId": outputRootItemId]],
                                                                           "inputs": [["schemaItemId": inputRootItemId]]]],
                                                    "schemaItems": [outputRootItemId: ["name": "Output item",
                                                                                       "children": [:]],
                                                                     inputRootItemId: ["name": "Input item",
                                                                                       "children": [:]]]]
                        let keyPath: [Any] = ["response", "transformations", transformationId]
                        store.send(.setValue(keyPath: keyPath, value: value))
                        sharedState.transformationId = transformationId
                        sharedState.menu = .transformation
                    }) {
                        Text("Create Transformation")
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
                ScrollView {
                    let availableWidth = geometry.size.width - 100 // Subtract width of other view
                    let columnCount = max(Int(availableWidth / 300), 1) // Adjust item width as needed
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columnCount), spacing: 10) {
                        ForEach(transformations.keys.sorted(), id: \.self) { transformationId in
                            if let transformation = transformations[transformationId] {
                                Button(action: {
                                    self.sharedState.transformationId = transformationId
                                    sharedState.menu = .transformation
                                    runTransformation(transformationId: transformationId, sharedState: sharedState, store: store)
                                }) {
                                    HStack {
                                        Image(systemName: "circle.hexagonpath")
                                            .padding()
                                        VStack {
                                            Text(transformation.name)
                                                .font(.headline)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(2)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                            //if let tags = transformation.tags {
                                            Text(["itx", "tutorial"] .map { "#\($0)" }.joined(separator: " ")) //tags
                                                .font(.caption)
                                                .foregroundColor(.green)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            //}
                                        }
                                        Spacer()
                                    }
                                    .frame(width: 300, height: 64)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(white: 0.11))
                                )
                                .buttonBorderShape(.roundedRectangle(radius: 10))
                            }
                        }
                    }
                    .padding()
                }
            }.padding()
        }
    }
}


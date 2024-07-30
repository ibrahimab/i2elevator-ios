//
//  TransformationListView.swift
//  i2Elevator
//
//  Created by János Kukoda on 30/07/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture

struct TransformationMenuSections: View {
    let store: StoreOf<UserFeature>
    @EnvironmentObject var sharedState: SharedState
    let geometry: GeometryProxy
    
    var body: some View {
        if let transformations = store.userDTO?.teams?["response"]?.transformations,
           let transformationId = sharedState.transformationId,
           let transformation = transformations[transformationId]
        {
            Group {
                Section {
                    HStack {
                        Text("Sub Transformations").bold()
                        Spacer()
                        //Image(systemName: "chevron.down")
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding()
                    ForEach(transformation.subTransformations.keys.sorted(), id: \.self) { subTransformationId in
                        if let subTransformation = transformation.subTransformations[subTransformationId] {
                            Button(action: {
                                sharedState.menu = .subTransformation
                                self.sharedState.subTransformationId = subTransformationId
                            }) {
                                HStack {
                                    Text(subTransformation.name).fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .padding()
                        }
                    }
                }
                .background(Color.init(white: 0.35))
                Section {
                    HStack {
                        Text("Input - Expected Output Pairs").bold()
                        Spacer()
                        //Image(systemName: "chevron.down")
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding()
                    if let inputExpectedOutputTextIdPairs = transformation.inputExpectedOutputTextIdPairs {
                        ForEach(Array(inputExpectedOutputTextIdPairs.keys.sorted()), id: \.self) { key in
                            Button(action: {
                                self.sharedState.menu = .inputExpectedOutputPair
                                self.sharedState.inputExpectedOutputPairId = key
                            }) {
                                HStack {
                                    Text("\(key)")
                                    Spacer()
                                    if key == sharedState.inputExpectedOutputPairId {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                    Image(systemName: "chevron.right").padding(.leading, 8)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .padding()
                        }
                    }
                }
                .background(Color.init(white: 0.35))
                Button(action: {
                    sharedState.menu = .schemaItemList
                }) {
                    HStack {
                        Text("Schema items").bold()
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .padding()
                .background(Color.init(white: 0.35))
            }
        }
    }
}


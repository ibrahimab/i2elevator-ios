//
//  FunctionCatalog.swift
//  i2Elevator
//
//  Created by János Kukoda on 07/03/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture
import Combine

struct RightView: View {
    @EnvironmentObject var sharedState: SharedState
    let store: StoreOf<UserFeature>
    @State private var showDocumentPickerTypeTree = false
    @State private var showDocumentPickerTransformation = false
    @State private var filename: String?
    @State private var documentDataTypeTree: Data? = nil
    @State private var documentDataTransformation: Data? = nil
    @State private var searchText: String = ""
    @State private var editedSchemaItem: SchemaItem? = nil
    @State private var editedSchemaItemId: String? = nil
    @State private var isSchemaItemEdited: Bool = false
    @State private var isSchemaItemRelationshipEdited: Bool = false
    @State private var editedParentSchemaItemId: String? = nil
    @State private var editedSchemaItemRelationship: SchemaItemRelationship? = nil
    
    var body: some View {
        VStack {
            if let transformationId = sharedState.transformationId,
               sharedState.menu == .transformation
            {
                HStack {
                    Button(action: {
                        let id = randomAlphaNumeric(length: 4)
                        let inputTextId = randomAlphaNumeric(length: 4)
                        let expectedOutputTextId = randomAlphaNumeric(length: 4)
                        let value: [String: Any] = ["inputTextId": inputTextId, "expectedOutputTextId": expectedOutputTextId]
                        let keyPath: [Any] = ["response", "transformations", transformationId, "inputExpectedOutputTextIdPairs", id]
                        store.send(.setValue(keyPath: keyPath, value: value))
                    }) {
                        Text("Create input - expected output pair")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    Spacer()
                }
                HStack {
                    Button(action: {
                        self.showDocumentPickerTypeTree.toggle()
                    }) {
                        Text("Import external xml typetree")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .sheet(isPresented: $showDocumentPickerTypeTree) {
                        DocumentPickerViewController(isPresented: self.$showDocumentPickerTypeTree, documentData: self.$documentDataTypeTree, filename: $filename)
                    }.onReceive(Just(documentDataTypeTree)) { documentData in
                        guard let documentData = documentData else { return }
                        let value = String(data: documentData, encoding: .utf8) ?? ""
                        let keyPath: [Any] = ["response", "transformations", transformationId, "externalTypeTree"]
                        store.send(.setValue(keyPath: keyPath, value: value))
                        let currentDate = Date()
                        let isoFormatter = ISO8601DateFormatter()
                        let value2 = isoFormatter.string(from: currentDate)
                        let keyPath2: [Any] = ["response", "transformations", transformationId, "externalTypeTreeUpdatedAt"]
                        store.send(.setValue(keyPath: keyPath2, value: value2))
                    }
                    Spacer()
                }
                HStack {
                    Button(action: {
                        self.showDocumentPickerTransformation.toggle()
                    }) {
                        Text("Import external xml transformation")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .sheet(isPresented: $showDocumentPickerTransformation) {
                        DocumentPickerViewController(isPresented: self.$showDocumentPickerTransformation, documentData: self.$documentDataTransformation, filename: $filename)
                    }.onReceive(Just(documentDataTransformation)) { documentData in
                        guard let documentData = documentData else { return }
                        let value = String(data: documentData, encoding: .utf8) ?? ""
                        let keyPath: [Any] = ["response", "transformations", transformationId, "externalTransformation"]
                        store.send(.setValue(keyPath: keyPath, value: value))
                        let currentDate = Date()
                        let isoFormatter = ISO8601DateFormatter()
                        let value2 = isoFormatter.string(from: currentDate)
                        let keyPath2: [Any] = ["response", "transformations", transformationId, "externalTransformationUpdatedAt"]
                        store.send(.setValue(keyPath: keyPath2, value: value2))
                    }
                    Spacer()
                }
                HStack {
                    Button(action: {
                        let keyPath: [Any] = ["response", "transformations", transformationId]
                        //store.send(.removeKey(keyPath: keyPath))
                        sharedState.transformationId = nil
                        sharedState.menu = .transformationList
                    }) {
                        Text("Delete transformation")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    Spacer()
                }
            } else if let transformationId = sharedState.transformationId,
                      sharedState.menu == .inputExpectedOutputPair
            {
                HStack {
                    Button(action: {
                        runTransformation(transformationId: transformationId, sharedState: sharedState, store: store)
                    }) {
                        Text("Run transformation")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    Spacer()
                }
            } else if sharedState.menu == .subTransformation,
                      let transformations = store.userDTO?.teams?["response"]?.transformations,
                      let transformationId = sharedState.transformationId,
                      let transformation = transformations[transformationId]
            {
                List {
                    ForEach(signatureCategories.indices, id: \.self) { index in
                        Section(header: Text(signatureCategories[index].name)) {
                            ForEach(Array(signatureCategories[index].functions.keys.sorted()), id: \.self) { key in
                                Button(action: {
                                    sharedState.selectedFunctionName = key
                                }) {
                                    Text(key)
                                }.onDrag {
                                    resetDragProperties()
                                    sharedState.draggedFunctionName = key
                                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                                    return itemProvider
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                if
                    let schemaItemId = sharedState.selectedSchemaItemId,
                    let schemaItem = transformation.schemaItems[schemaItemId]
                {
                    List {
                        if let schemaItemId = sharedState.selectedSchemaItemId,
                           let _ = store.state.userDTO?.teams?["response"]?.transformations[transformationId]?.schemaItems[schemaItemId]
                        {
                            RightViewContent(
                                editedSchemaItem: $editedSchemaItem,
                                isSchemaItemEdited: $isSchemaItemEdited,
                                isSchemaItemRelationshipEdited: $isSchemaItemRelationshipEdited,
                                editedSchemaItemRelationship: $editedSchemaItemRelationship,
                                sharedState: sharedState,
                                store: store,
                                transformationId: transformationId,
                                schemaItemId: schemaItemId
                            )
                        }
                    }
                    HStack {
                        Button(action: {
                            let encoder = JSONEncoder()
                            if isSchemaItemEdited {
                                if let jsonData = try? encoder.encode(editedSchemaItem),
                                   let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                                {
                                    let keyPath: [Any] = ["response", "transformations", transformationId, "schemaItems", schemaItemId]
                                    store.send(.setValue(keyPath: keyPath, value: dictionary))
                                }
                                isSchemaItemEdited = false
                            }
                            if isSchemaItemRelationshipEdited,
                               let selectedParentSchemaItemId = sharedState.selectedParentSchemaItemId
                            {
                                if let jsonData = try? encoder.encode(editedSchemaItemRelationship),
                                   let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                                {
                                    let keyPath: [Any] = ["response", "transformations", transformationId, "schemaItems", selectedParentSchemaItemId, "children", schemaItemId]
                                    store.send(.setValue(keyPath: keyPath, value: dictionary))
                                }
                                isSchemaItemRelationshipEdited = false
                            }
                            runTransformation(transformationId: transformationId, sharedState: sharedState, store: store)
                        }) {
                            Text("Save")
                        }
                        .disabled(!isSchemaItemEdited && !isSchemaItemRelationshipEdited)
                        .foregroundColor(.white)
                        .background((isSchemaItemEdited || isSchemaItemRelationshipEdited) ? Color.blue : Color.gray)
                        .cornerRadius(24)
                        .buttonStyle(BorderedButtonStyle())
                    }.padding(.horizontal, 24)
                }
            }
            Spacer()
        }
        .padding()
        .onChange(of: sharedState.selectedSchemaItemId, initial: true) { old, selectedSchemaItemId  in
            if let transformations = store.userDTO?.teams?["response"]?.transformations,
               let transformationId = sharedState.transformationId,
               let transformation = transformations[transformationId],
               let schemaItemId = selectedSchemaItemId,
               let schemaItem = transformation.schemaItems[schemaItemId]
            {
                editedSchemaItem = schemaItem
                if let selectedParentSchemaItemId = sharedState.selectedParentSchemaItemId,
                   let selectedParentSchemaItem = transformation.schemaItems[selectedParentSchemaItemId]
                {
                    editedSchemaItemRelationship = selectedParentSchemaItem.children[schemaItemId]
                }
            }
        }
    }
}

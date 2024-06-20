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
    
    var body: some View {
        VStack {
            if let transformationId = sharedState.transformationId,
               sharedState.menu == .transformation
            {
                HStack {
                    Button(action: {
                        let inputTextId = randomAlphaNumeric(length: 4)
                        let expectedOutputTextId = randomAlphaNumeric(length: 4)
                        let value: [String: Any] = ["inputTextId": inputTextId, "expectedOutputTextId": expectedOutputTextId]
                        let c = store.userDTO?.teams?["response"]?.transformations[transformationId]?.inputExpectedOutputTextIdPairs?.count ?? 0
                        let keyPath: [Any] = ["response", "transformations", transformationId, "inputExpectedOutputTextIdPairs", c]
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
                      let transformation = transformations[transformationId],
                      let schemaItemId = sharedState.selectedSchemaItemId,
                      let schemaItem = transformation.schemaItems[schemaItemId]
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
                List {
                    Section(header: Text("Scheme Item Name")) {
                        TextField("Scheme Item Name", text: Binding(
                            get: { editedSchemaItem?.name ?? "" },
                            set: {
                                editedSchemaItem?.name = $0
                                isSchemaItemEdited = true
                            }
                        )).autocapitalization(.none)
                    }
                    Section(header: Text("Initiator")) {
                        TextField("Enter Initiator", text: Binding(
                            get: { editedSchemaItem?.initiator ?? "" },
                            set: {
                                editedSchemaItem?.initiator = $0
                                isSchemaItemEdited = true
                            }
                        )).autocapitalization(.none)
                    }
                    Section(header: Text("Terminator")) {
                        TextField("Enter Initiator", text: Binding(
                            get: { editedSchemaItem?.terminator ?? "" },
                            set: {
                                editedSchemaItem?.terminator = $0
                                isSchemaItemEdited = true
                            }
                        )).autocapitalization(.none)
                    }
                    Section(header: Text("Delimiter")) {
                        TextField("Enter Initiator", text: Binding(
                            get: { editedSchemaItem?.delimiter ?? "" },
                            set: {
                                editedSchemaItem?.delimiter = $0
                                isSchemaItemEdited = true
                            }
                        )).autocapitalization(.none)
                    }
                    Section(header: Text("Type")) {
                        TextField("Enter Initiator", text: Binding(
                            get: { editedSchemaItem?.type ?? "" },
                            set: {
                                editedSchemaItem?.type = $0
                                isSchemaItemEdited = true
                            }
                        )).autocapitalization(.none)
                    }
                }
                HStack {
                    Button(action: {
                        let encoder = JSONEncoder()
                        if let jsonData = try? encoder.encode(editedSchemaItem),
                           let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        {
                            let keyPath: [Any] = ["response", "transformations", transformationId, "schemaItems", schemaItemId]
                            store.send(.setValue(keyPath: keyPath, value: dictionary))
                        }
                        isSchemaItemEdited = false
                        runTransformation(transformationId: transformationId, sharedState: sharedState, store: store)
                    }) {
                        Text("Save")
                    }
                    .disabled(!isSchemaItemEdited)
                    .foregroundColor(.white)
                    .background(isSchemaItemEdited ? Color.blue : Color.gray)
                    .cornerRadius(24)
                    .buttonStyle(BorderedButtonStyle())
                }.padding(.horizontal, 24)
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
            }
        }
    }
}

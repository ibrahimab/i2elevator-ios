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
                        store.send(.removeKey(keyPath: keyPath))
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
                VStack {
                    HStack {
                        Button(action: {
                            guard let selectedSchemaItemId = sharedState.selectedSchemaItemId else {
                                return
                            }
                            guard let schemaItem = transformation.schemaItems[selectedSchemaItemId] else {
                                return
                            }
                            let schemaItemId = randomAlphaNumeric(length: 4)
                            let value: [String: Any] = ["name": "New schema item",
                                                        "children": [:]]
                            let keyPath: [Any] = ["response", "transformations", transformationId, "schemaItems", schemaItemId]
                            store.send(.setValue(keyPath: keyPath, value: value))
                            let value2: [String: Any] = ["rangeMax": "1", "rowNum": schemaItem.children.count + 1]
                            let keyPath2: [Any] = ["response", "transformations", transformationId, "schemaItems", selectedSchemaItemId, "children", schemaItemId]
                            store.send(.setValue(keyPath: keyPath2, value: value2))
                            sharedState.selectedParentSchemaItemId = sharedState.selectedSchemaItemId
                            sharedState.selectedSchemaItemId = schemaItemId
                        }) {
                            Text("Add child schema item")
                        }
                        .buttonStyle(BorderedButtonStyle())
                        Spacer()
                    }.padding()
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
                            TextEditor(text: Binding(
                                get: { editedSchemaItem?.initiator ?? "" },
                                set: {
                                    editedSchemaItem?.initiator = $0
                                    isSchemaItemEdited = true
                                }
                            )).autocapitalization(.none)
                        }
                        Section(header: Text("Terminator")) {
                            TextField("Enter Terminator", text: Binding(
                                get: { editedSchemaItem?.terminator ?? "" },
                                set: {
                                    editedSchemaItem?.terminator = $0
                                    isSchemaItemEdited = true
                                }
                            )).autocapitalization(.none)
                        }
                        Section(header: Text("Delimiter")) {
                            TextField("Enter Delimiter", text: Binding(
                                get: { editedSchemaItem?.delimiter ?? "" },
                                set: {
                                    editedSchemaItem?.delimiter = $0
                                    isSchemaItemEdited = true
                                }
                            )).autocapitalization(.none)
                        }
                        if editedSchemaItemRelationship?.rangeMax == "S" {
                            Section(header: Text("1-S Delimiter")) {
                                TextField("Enter Delimiter", text: Binding(
                                    get: { editedSchemaItemRelationship?.delimiter ?? "" },
                                    set: {
                                        editedSchemaItemRelationship?.delimiter = $0
                                        isSchemaItemRelationshipEdited = true
                                    }
                                )).autocapitalization(.none)
                            }
                        }
                        Section(header: Text("Type")) {
                            TextField("Enter Type", text: Binding(
                                get: { editedSchemaItem?.type ?? "" },
                                set: {
                                    editedSchemaItem?.type = $0
                                    isSchemaItemEdited = true
                                }
                            )).autocapitalization(.none)
                        }
                        Section(header: Text("Cardinality")) {
                            TextField("1 or S", text: Binding(
                                get: { editedSchemaItemRelationship?.rangeMax ?? "1" },
                                set: {
                                    editedSchemaItemRelationship?.rangeMax = $0
                                    isSchemaItemRelationshipEdited = true
                                }
                            )).autocapitalization(.none)
                        }
                        Section(header: Text("Row Number")) {
                            TextField("1", text: Binding(
                                get: { "\(editedSchemaItemRelationship?.rowNum ?? 1)"},
                                set: {
                                    if let ii = Int($0) {
                                        editedSchemaItemRelationship?.rowNum = ii
                                        isSchemaItemRelationshipEdited = true
                                    } else {
                                        print("Conversion failed")
                                    }
                                }
                            )).autocapitalization(.none)
                        }
                    }
                    HStack {
                        Button(action: {
                            guard let selectedSchemaItemId = sharedState.selectedSchemaItemId else {
                                return
                            }
                            guard let selectedParentSchemaItemId = sharedState.selectedParentSchemaItemId else {
                                return
                            }
                            guard let schemaItem = transformation.schemaItems[selectedSchemaItemId] else {
                                return
                            }
                            let keyPath: [Any] = ["response", "transformations", transformationId, "schemaItems", selectedParentSchemaItemId, "children", selectedSchemaItemId]
                            store.send(.removeKey(keyPath: keyPath))
                            let keyPath2: [Any] = ["response", "transformations", transformationId, "schemaItems", selectedSchemaItemId]
                            store.send(.removeKey(keyPath: keyPath2))
                            // TODO: Navigate one up
                            sharedState.selectedParentSchemaItemId = nil
                            sharedState.selectedSchemaItemId = nil
                        }) {
                            Text("Remove child schema item")
                        }
                        .buttonStyle(BorderedButtonStyle())
                        Spacer()
                    }.padding()
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

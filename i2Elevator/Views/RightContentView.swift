//
//  RightContentView.swift
//  i2Elevator
//
//  Created by János Kukoda on 07/08/2024.
//

import SwiftUI
import ComposableArchitecture

struct RightViewContent: View {
    @Binding var editedSchemaItem: SchemaItem?
    @Binding var isSchemaItemEdited: Bool
    @Binding var isSchemaItemRelationshipEdited: Bool
    @Binding var editedSchemaItemRelationship: SchemaItemRelationship?
    let sharedState: SharedState
    let store: StoreOf<UserFeature>
    let transformationId: String
    let schemaItemId: String
    
    var body: some View {
        Group {
            Button(action: {
                guard let selectedSchemaItemId = sharedState.selectedSchemaItemId else {
                    return
                }
                guard let schemaItem = store.state.userDTO?.teams?["response"]?.transformations[transformationId]?.schemaItems[selectedSchemaItemId] else {
                    return
                }
                let newSchemaItemId = randomAlphaNumeric(length: 4)
                let value: [String: Any] = ["name": "New schema item",
                                            "children": [:]]
                let keyPath: [Any] = ["response", "transformations", transformationId, "schemaItems", newSchemaItemId]
                store.send(.setValue(keyPath: keyPath, value: value))
                let value2: [String: Any] = ["rangeMax": "1", "rowNum": schemaItem.children.count + 1]
                let keyPath2: [Any] = ["response", "transformations", transformationId, "schemaItems", selectedSchemaItemId, "children", newSchemaItemId]
                store.send(.setValue(keyPath: keyPath2, value: value2))
                sharedState.selectedParentSchemaItemId = sharedState.selectedSchemaItemId
                sharedState.selectedSchemaItemId = newSchemaItemId
            }) {
                Text("Add child schema item")
            }
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
                    get: { "\(editedSchemaItemRelationship?.rowNum ?? 1)" },
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
            Button(action: {
                guard let selectedSchemaItemId = sharedState.selectedSchemaItemId else {
                    return
                }
                guard let selectedParentSchemaItemId = sharedState.selectedParentSchemaItemId else {
                    return
                }
                guard let schemaItem = store.state.userDTO?.teams?["response"]?.transformations[transformationId]?.schemaItems[selectedSchemaItemId] else {
                    return
                }
                let keyPath: [Any] = ["response", "transformations", transformationId, "schemaItems", selectedParentSchemaItemId, "children", selectedSchemaItemId]
                store.send(.removeKey(keyPath: keyPath))
                let keyPath2: [Any] = ["response", "transformations", transformationId, "schemaItems", selectedSchemaItemId]
                store.send(.removeKey(keyPath: keyPath2))
                sharedState.selectedParentSchemaItemId = nil
                sharedState.selectedSchemaItemId = nil
            }) {
                Text("Remove child schema item")
            }
            Button(action: {
                sharedState.menu = .mapRuleTest
            }) {
                Text("Show map rule test cases")
            }
        }
    }
}

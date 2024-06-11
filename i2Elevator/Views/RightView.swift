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
                        let url = URL(string: "\(baseUrl)/transform")!
                        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                        components.queryItems = [
                            URLQueryItem(name: "transformationId", value: transformationId)
                        ]
                        var request = URLRequest(url: components.url!)
                        request.httpMethod = "POST"
                        request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
                        
                        // sharedState.userDTO?.teams?["response"]?.transformations[transformationId]?.subTransformations[subTransformationInd]
                        guard let inputExpectedOutputPairInd = sharedState.inputExpectedOutputPairInd else {
                            return
                        }
                        
                        guard let tid = store.userDTO?.teams?["response"]?.transformations[transformationId]?.inputExpectedOutputTextIdPairs?[inputExpectedOutputPairInd].inputTextId else {
                            return
                        }
                        guard var text = store.userDTO?.teams?["response"]?.texts?[tid] else {
                            return
                        }
                        if !text.isEmpty {
                            text.removeFirst()
                        } else {
                            // Handle the case where the string is empty
                            return
                        }
                        request.httpBody = text.data(using: .utf8)
                        //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            do {
                                if let data = data {
                                    if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                        DispatchQueue.main.async {
                                            // Access your dictionary data here
                                            print(jsonDictionary)
                                            sharedState.output = jsonDictionary
                                        }
                                    }
                                }
                            } catch {
                                // Handle the error here
                                print("Error: \(error)")
                            }
                        }
                        task.resume()
                    }) {
                        Text("Run transformation")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .buttonStyle(BorderedButtonStyle())
                    Spacer()
                }
            } /*else if sharedState.menu == .transformationList
            {
                VStack {
                    /*HStack {
                        TextField("Search", text: $searchText)
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 40)*/
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
                    Spacer()
                }
            }*/ else {
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
            }
            Spacer()
        }.padding()
    }
}

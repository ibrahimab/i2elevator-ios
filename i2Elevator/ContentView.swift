//
//  ContentView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import ComposableArchitecture

let barTransparency = 0.01

class SharedState: ObservableObject {
    @Published var transformationId: String? = nil
    @Published var subTransformationId: String? = nil
    @Published var cardType: String? = nil
    @Published var cardIndex: Int? = nil
    @Published var draggedSchemaItem: DraggedSchemaItem? = nil
    @Published var outputItemId: String? = nil
    @Published var draggedFunctionName: String? = nil
    @Published var expressionKeypathSegment: [Any]? = nil
    @Published var schemaItemsOnScratchpad: [DraggedSchemaItem] = []
    @Published var functionCategoryIndex: Int = 0
    @Published var schemaItemId: String? = nil
    @Published var childSchemaItemId: String? = nil
    @Published var isFunctionCatalogCombined: Bool = true
    @Published var selectedFunctionName: String? = nil
    @Published var viewStack: [ViewDropData] = []
    @Published var viewToDrop: ViewDropData? = nil
    @Published var output: [String : Any]?
    @Published var menu: SelectedMenuItem = .none
    @Published var inputExpectedOutputPairInd: Int? = nil
}

enum SelectedMenuItem {
    case none
    case subTransformation
    case transformation
    case schemaItemList
    case schemaItem
    case inputExpectedOutputPair
}

struct ViewDropData {
    var name: String
    var cardType: String?
    var cardIndex: Int?
}

struct ContentView: View {
    @EnvironmentObject var sharedState: SharedState
    @State private var searchText: String = ""
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var yMovement: CGFloat = 0.0
    @State private var x1Movement: CGFloat = 0.0
    @State private var x2Movement: CGFloat = 0.0
    let store: StoreOf<UserFeature>
    @State private var editedSchemaItem: SchemaItem? = nil
    @State private var isSchemaItemEdited: Bool = false
    @State private var isLeftBarHighlighted: Bool = false
    @State private var isRightBarHighlighted: Bool = false
    @State private var isCenterBarHighlighted: Bool = false
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    if sharedState.menu == .subTransformation,
                       let transformations = store.userDTO?.teams?["response"]?.transformations,
                       let transformationId = sharedState.transformationId,
                       let subTransformations = transformations[transformationId]?.subTransformations,
                       let subTransformationId = sharedState.subTransformationId,
                       let subTransformationName = subTransformations[subTransformationId]?.name
                    {
                        HStack {
                            Button(action: {
                                sharedState.menu = .transformation
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            .clipShape(Circle())
                            Spacer()
                            TextField("Search", text: $searchText)
                            Spacer()
                            Button(action: {
                                
                            }) {
                                Image(systemName: "gear")
                            } .clipShape(Circle())
                        }
                        .padding(.bottom, 40)
                        .padding(.horizontal, 20)
                        List {
                            if let cards = subTransformations[subTransformationId]?.inputs {
                                Section(header: Text("\(subTransformationName) > Card In")) {
                                    ForEach(cards.indices, id: \.self) { index in
                                        Button(action: {
                                            let viewDropData = ViewDropData(name: "SubTransformationView", cardType: "in", cardIndex: index)
                                            sharedState.viewStack.append(viewDropData)
                                        }) {
                                            HStack {
                                                Text("Card") //cards[index].name
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                    }
                                }
                            }
                            if let cards = subTransformations[subTransformationId]?.outputs {
                                Section(header: Text("Card Out")) {
                                    ForEach(cards.indices, id: \.self) { index in
                                        Button(action: {
                                            let viewDropData = ViewDropData(name: "SubTransformationView", cardType: "out", cardIndex: index)
                                            sharedState.viewStack.append(viewDropData)
                                        }) {
                                            HStack {
                                                Text("Card") //cards[index].name
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else if sharedState.menu == .transformation || sharedState.menu == .inputExpectedOutputPair,
                              let transformations = store.userDTO?.teams?["response"]?.transformations,
                              let transformationId = sharedState.transformationId,
                              let transformation = transformations[transformationId]
                    {
                        HStack {
                            Button(action: {
                                if sharedState.inputExpectedOutputPairInd != nil {
                                    sharedState.inputExpectedOutputPairInd = nil
                                    sharedState.menu = .transformation
                                } else {
                                    sharedState.menu = .none
                                }
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            .clipShape(Circle())
                            Spacer()
                            TextField("Search", text: $searchText)
                        }
                        .padding(.bottom, 40)
                        .padding(.horizontal, 20)
                        Spacer()
                        List {
                            Section(header: Text("Transformation name")) {
                                Text(transformation.name)
                            }
                            Section(header: Text("Sub Transformations")) {
                                ForEach(transformation.subTransformations.keys.sorted(), id: \.self) { subTransformationId in
                                    if let subTransformation = transformation.subTransformations[subTransformationId] {
                                        Button(action: {
                                            sharedState.menu = .subTransformation
                                            self.sharedState.subTransformationId = subTransformationId
                                        }) {
                                            HStack {
                                                Text(subTransformation.name)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                    }
                                }
                            }
                            Section(header: Text("Input - Expected Output Pairs")) {
                                if let inputExpectedOutputTextIdPairs = transformation.inputExpectedOutputTextIdPairs {
                                    ForEach(Array(inputExpectedOutputTextIdPairs.enumerated()), id: \.element.inputTextId) { index, inputExpectedOutputTextIdPair in
                                        Button(action: {
                                            self.sharedState.menu = .inputExpectedOutputPair
                                            self.sharedState.inputExpectedOutputPairInd = index
                                        }) {
                                            HStack {
                                                Text("\(index)")
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                    }
                                }
                            }
                            Section(header: Text("")) {
                                Button(action: {
                                    sharedState.menu = .schemaItemList
                                }) {
                                    HStack {
                                        Text("Schema items")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            }
                        }
                    } else if sharedState.menu == .schemaItem,
                              let transformations = store.userDTO?.teams?["response"]?.transformations,
                              let transformationId = sharedState.transformationId,
                              let transformation = transformations[transformationId],
                              let schemaItemId = sharedState.schemaItemId,
                              let childSchemaItemId = sharedState.childSchemaItemId,
                              let schemaItem = transformation.schemaItems[schemaItemId],
                              let childSchemaItem = transformation.schemaItems[childSchemaItemId]
                    {
                        HStack {
                            Button(action: {
                                sharedState.childSchemaItemId = nil
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            .clipShape(Circle())
                            Spacer()
                            TextField("Search", text: $searchText)
                        }
                        .padding(.bottom, 40)
                        .padding(.horizontal, 20)
                        HStack {
                            Spacer()
                            Button(action: {
                                
                            }) {
                                Text(schemaItem.children[childSchemaItemId] == nil ? "Remove child schema item from parent" : "Assign item to \(schemaItem.name)")
                            }
                        }.padding(.horizontal, 20)
                        HStack {
                            Spacer()
                            Button(action: {
                                
                            }) {
                                Text("Delete child schema item")
                            }
                        }.padding(.bottom, 40)
                            .padding(.horizontal, 20)
                        List {
                            Section(header: Text(schemaItem.children[childSchemaItemId] != nil ? "Unassigned Schema Item" : "Assigned Schema Item")) {
                                Text(childSchemaItem.name)
                            }
                            if let rangeMax = transformation.schemaItems[schemaItemId]?.children[childSchemaItemId]?.rangeMax {
                                Section(header: Text("Cardinality")) {
                                    Text(rangeMax)
                                }
                            }
                        }
                        Spacer()
                    } else if sharedState.menu == .schemaItem,
                              let transformations = store.userDTO?.teams?["response"]?.transformations,
                              let transformationId = sharedState.transformationId,
                              let transformation = transformations[transformationId],
                              let schemaItemId = sharedState.schemaItemId,
                              let schemaItem = transformation.schemaItems[schemaItemId]
                    {
                        HStack {
                            Button(action: {
                                sharedState.menu = .schemaItemList
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            .clipShape(Circle())
                            Spacer()
                            TextField("Search", text: $searchText)
                        }
                        .padding(.bottom, 40)
                        .padding(.horizontal, 20)
                        Spacer()
                        List {
                            Section(header: Text("\(transformation.name) > Schema Items")) {
                                TextField("Enter Initiator", text: Binding(
                                    get: { editedSchemaItem?.name ?? "" }, 
                                    set: {
                                        editedSchemaItem?.name = $0
                                        isSchemaItemEdited = true
                                    }
                                )).autocapitalization(.none)
                            }
                            Section(header: Text("Children")) {
                                ForEach(transformation.schemaItems.keys.sorted(), id: \.self) { childSchemaItemId in
                                    if let childSchemaItem = transformation.schemaItems[childSchemaItemId] {
                                        Button(action: {
                                            self.sharedState.childSchemaItemId = childSchemaItemId
                                        }) {
                                            HStack {
                                                Text(childSchemaItem.name)
                                                    .foregroundColor(schemaItem.children[childSchemaItemId] == nil ? .white : .blue)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                    }
                                }
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
                            Spacer()
                            Button(action: {
                                let encoder = JSONEncoder()
                                if let jsonData = try? encoder.encode(editedSchemaItem),
                                   let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                                {
                                    let keyPath: [Any] = ["response", "transformations", transformationId, "schemaItems", schemaItemId]
                                    store.send(.setValue(keyPath: keyPath, value: dictionary))
                                }
                                isSchemaItemEdited = false
                            }) {
                                Text("Save")
                            }
                            .disabled(!isSchemaItemEdited)
                            .foregroundColor(.white)
                            .background(isSchemaItemEdited ? Color.blue : Color.gray)
                            .cornerRadius(24)
                        }.padding(.horizontal, 24)
                    } else if sharedState.menu == .schemaItemList,
                              let transformations = store.userDTO?.teams?["response"]?.transformations,
                              let transformationId = sharedState.transformationId,
                              let transformation = transformations[transformationId]
                    {
                        HStack {
                            Button(action: {
                                sharedState.menu = .transformation
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            .clipShape(Circle())
                            Spacer()
                            TextField("Search", text: $searchText)
                        }
                        .padding(.bottom, 40)
                        .padding(.horizontal, 20)
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                let schemaItemId = randomAlphaNumeric(length: 4)
                                let value: [String: Any] = ["name": "New schema item",
                                                            "children": [:]]
                                let keyPath: [Any] = ["response", "transformations", transformationId, "schemaItems", schemaItemId]
                                store.send(.setValue(keyPath: keyPath, value: value))
                            }) {
                                Text("Add schema item")
                            }
                        }.padding(.bottom, 40)
                            .padding(.horizontal, 20)
                        Spacer()
                        List {
                            Section(header: Text("\(transformation.name) > Schema Items")) {
                                ForEach(transformation.schemaItems.keys.sorted(), id: \.self) { schemaItemId in
                                    if let schemaItem = transformation.schemaItems[schemaItemId] {
                                        Button(action: {
                                            sharedState.menu = .schemaItem
                                            self.sharedState.schemaItemId = schemaItemId
                                            editedSchemaItem = schemaItem
                                        }) {
                                            HStack {
                                                Text(schemaItem.name)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else if let transformations = store.userDTO?.teams?["response"]?.transformations {
                        HStack {
                            TextField("Search", text: $searchText)
                        }
                        .padding(.bottom, 40)
                        .padding(.horizontal, 40)
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
                        List {
                            Section(header: Text("Transformations")) {
                                ForEach(transformations.keys.sorted(), id: \.self) { transformationId in
                                    if let transformation = transformations[transformationId] {
                                        Button(action: {
                                            self.sharedState.transformationId = transformationId
                                            sharedState.menu = .transformation
                                        }) {
                                            HStack {
                                                Text(transformation.name)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.padding(.vertical, 40).frame(width: 300 + x1Movement)                
                VStack {
                    CenterTopView(store: store).frame(height: geometry.size.height * 0.5 + yMovement)
                    HStack {
                        ForEach(sharedState.viewStack.indices, id: \.self) { stackItemIndex in
                            let stackItem = sharedState.viewStack[stackItemIndex]
                            if let cardType = stackItem.cardType,
                               let cardIndex = stackItem.cardIndex
                            {
                                CardView(cardIndex: cardIndex, cardType: cardType, store: store)
                            }
                        }
                    }.onDrop(of:  [UTType.text], isTargeted: nil) { providers, location in
                        if let viewToDrop = sharedState.viewToDrop {
                            sharedState.viewStack.append(viewToDrop)
                            sharedState.viewToDrop = nil
                            if let cardIndex = viewToDrop.cardIndex,
                               let cardType = viewToDrop.cardType
                            {
                                dismissWindow(id: "SubTransformationView", value: MyData(intValue: cardIndex, stringValue: cardType))
                            } else {
                                dismissWindow(id: viewToDrop.name)
                            }
                        }
                        return true
                    }.frame(height: geometry.size.height * 0.5 - yMovement)
                }
                .overlay {
                    Button(action: {
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(width: 100, height: 8)
                                .cornerRadius(4)
                                .foregroundColor(Color.gray.opacity(0.8))
                            Rectangle()
                                .frame(width: geometry.size.width - 600 - x1Movement + x2Movement - 16, height: 8)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            yMovement = value.translation.height
                                        }
                                    }
                                )
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(Color.gray.opacity(barTransparency))
                    .offset(x: -8, y: yMovement)
                }
                RightView(store: store).frame(width: 300 - x2Movement)
            }.onAppear {
                let url = URL(string: "\(baseUrl)/auth/me")! //https://datamapper.vercel.app/api/auth/me"
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                components.queryItems = []
                let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyTmFtZSI6IkrDoW5vcyIsInVzZXJJZCI6IjY2MmYzYWE2ZDdiYWEyZGY5MjExODJiNCIsImVtYWlsIjoia3Vrb2RhamFub3NAaWNsb3VkLmNvbSIsImlhdCI6MTcxNTMxMTI3OSwiZXhwIjoxNzE3OTAzMjc5fQ.I4bbviNSMDZcvZYc1Jf07nZUVVrXsOOA8M9Ig3hJp0s"
                var request = URLRequest(url: components.url!)
                request.httpMethod = "GET"
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    let decoder = JSONDecoder()
                    if let data = data {
                        do {
                            let authResponse = try decoder.decode(AuthResponse.self, from: data)
                            DispatchQueue.main.async {
                                if let userDTO = authResponse.data {
                                    store.send(.initialize(userDTO: userDTO))
                                }
                            }
                        } catch {
                            // Handle the error here
                            print("Error: \(error)")
                        }
                    }
                }
                task.resume()
                if let str = Bundle.main.path(forResource: "FunctionPropsTypes", ofType: "plist") {
                    let d = NSArray(contentsOfFile: str)
                    if let d = d {
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: d, options: [])
                        else {
                            // Handle errors
                            return
                        }
                        do {
                            let jsonDecoder = JSONDecoder()
                            signatureCategories = try jsonDecoder.decode([SignatureCategory].self, from: jsonData )
                        } catch {
                            // Handle decoding error
                            print("Decoding error: \(error)")
                        }
                    }
                }
            }.overlay {
                Button(action: {
                }) {
                    ZStack {
                        Rectangle()
                            .frame(width: 8, height: 100)
                            .cornerRadius(4)
                            .foregroundColor(Color.gray.opacity(0.8))
                        Rectangle()
                            .frame(width: 8, height: geometry.size.height)
                            .gesture(DragGesture()
                                .onChanged { value in
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        x1Movement = value.translation.width
                                    }
                                }
                            )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(Color.gray.opacity(barTransparency))
                .offset(x: x1Movement - geometry.size.width / 2.0 + 300.0 - 8.0, y: 0)
                Button(action: {
                }) {
                    ZStack {
                        Rectangle()
                            .frame(width: 8, height: 100)
                            .cornerRadius(4)
                            .foregroundColor(Color.gray.opacity(0.8))
                        Rectangle()
                            .frame(width: 8, height: geometry.size.height)
                            .gesture(DragGesture()
                                .onChanged { value in
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        x2Movement = value.translation.width
                                    }
                                }
                            )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(Color.gray.opacity(barTransparency))
                .offset(x: x2Movement + geometry.size.width / 2.0 - 300.0 - 8.0, y: 0)
            }
        }
    }
}

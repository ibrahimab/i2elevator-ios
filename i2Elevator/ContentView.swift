//
//  ContentView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent
import UniformTypeIdentifiers
import ComposableArchitecture

let barTransparency = 0.5

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
}

enum SelectedMenuItem {
    case none
    case subTransformation
    case transformation
    case schemaItemList
    case schemaItem
}

struct ViewDropData {
    var name: String
    var cardType: String?
    var cardIndex: Int?
}

struct ContentView: View {
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.openWindow) private var openWindow
    @State private var menu: SelectedMenuItem = .none
    @State private var searchText: String = ""
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var yMovement: CGFloat = 0.0
    @State private var x1Movement: CGFloat = 0.0
    @State private var x2Movement: CGFloat = 0.0
    let store: StoreOf<UserFeature>
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    if self.menu == .subTransformation,
                       let transformations = store.userDTO?.teams?["response"]?.transformations,
                       let transformationId = sharedState.transformationId,
                       let subTransformations = transformations[transformationId]?.subTransformations,
                       let subTransformationId = sharedState.subTransformationId,
                       let subTransformationName = subTransformations[subTransformationId]?.name
                    {
                        HStack {
                            Button(action: {
                                self.menu = .transformation
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
                    } else if self.menu == .transformation,
                              let transformations = store.userDTO?.teams?["response"]?.transformations,
                              let transformationId = sharedState.transformationId,
                              let transformation = transformations[transformationId]
                    {
                        HStack {
                            Button(action: {
                                self.menu = .none
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
                            Section(header: Text("\(transformation.name) > Sub Transformations")) {
                                ForEach(transformation.subTransformations.keys.sorted(), id: \.self) { subTransformationId in
                                    if let subTransformation = transformation.subTransformations[subTransformationId] {
                                        Button(action: {
                                            self.menu = .subTransformation
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
                            Section(header: Text("")) {
                                Button(action: {
                                    self.menu = .schemaItemList
                                }) {
                                    HStack {
                                        Text("Schema items")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            }
                        }
                    } else if self.menu == .schemaItem,
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
                    } else if self.menu == .schemaItem,
                              let transformations = store.userDTO?.teams?["response"]?.transformations,
                              let transformationId = sharedState.transformationId,
                              let transformation = transformations[transformationId],
                              let schemaItemId = sharedState.schemaItemId,
                              let schemaItem = transformation.schemaItems[schemaItemId]
                    {
                        HStack {
                            Button(action: {
                                self.menu = .schemaItemList
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
                                Text(schemaItem.name)
                            }
                            Section(header: Text("Chidren")) {
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
                        }
                    } else if self.menu == .schemaItemList,
                              let transformations = store.userDTO?.teams?["response"]?.transformations,
                              let transformationId = sharedState.transformationId,
                              let transformation = transformations[transformationId]
                    {
                        HStack {
                            Button(action: {
                                self.menu = .transformation
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
                                            self.menu = .schemaItem
                                            self.sharedState.schemaItemId = schemaItemId
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
                        List {
                            Section(header: Text("Transformations")) {
                                ForEach(transformations.keys.sorted(), id: \.self) { transformationId in
                                    if let transformation = transformations[transformationId] {
                                        Button(action: {
                                            self.sharedState.transformationId = transformationId
                                            self.menu = .transformation
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
                    MapRuleEditor(store: store).frame(height: geometry.size.height * 0.5 + yMovement)
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
                    Rectangle()
                        .frame(width: 100, height: 8)
                        .cornerRadius(4)
                        .foregroundColor(Color.black.opacity(0.2))
                        .offset(x: 0, y: yMovement)
                    Rectangle()
                        .frame(width: geometry.size.width - 600 - x1Movement + x2Movement, height: 16)
                        .foregroundColor(Color.gray.opacity(barTransparency))
                        .offset(x: 0, y: yMovement)
                        .gesture(DragGesture()
                            .onChanged { value in
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    yMovement = value.translation.height
                                }
                            }
                        )
                }
                FunctionCatalog().frame(width: 300 - x2Movement)
            }.onAppear {
                let url = URL(string: "https://datamapper.vercel.app/api/auth/me")! //https://datamapper.vercel.app/api/auth/me"
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                components.queryItems = []
                let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyTmFtZSI6IkrDoW5vcyIsInVzZXJJZCI6IjY1M2Q3NWQzZWFhODdjODM3YTFkZDkwOCIsImVtYWlsIjoia3Vrb2RhamFub3NAaWNsb3VkLmNvbSIsImlhdCI6MTcxMzQ1NzExMiwiZXhwIjoxNzE2MDQ5MTEyfQ.MUiv_Z4ORIs84FOwKsb7LelEnE_vXnjwSr55AA9YBu8"
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
                Rectangle()
                    .frame(width: 8, height: 100)
                    .cornerRadius(4)
                    .foregroundColor(Color.black.opacity(0.2))
                    .offset(x: x1Movement - geometry.size.width / 2.0 + 300.0 - 8.0, y: 0)
                Rectangle()
                    .frame(width: 16, height: geometry.size.height)
                    .foregroundColor(Color.gray.opacity(barTransparency))
                    .gesture(DragGesture()
                        .onChanged { value in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                x1Movement = value.translation.width
                            }
                        }
                    )
                    .offset(x: x1Movement - geometry.size.width / 2.0 + 300.0 - 8.0, y: 0)
                Rectangle()
                    .frame(width: 8, height: 100)
                    .cornerRadius(4)
                    .foregroundColor(Color.black.opacity(0.2))
                    .offset(x: x2Movement + geometry.size.width / 2.0 - 300.0 - 8.0, y: 0)
                Rectangle()
                    .frame(width: 16, height: geometry.size.height)
                    .foregroundColor(Color.gray.opacity(barTransparency))
                    .gesture(DragGesture()
                        .onChanged { value in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                x2Movement = value.translation.width
                            }
                        }
                    )
                    .offset(x: x2Movement + geometry.size.width / 2.0 - 300.0 - 8.0, y: 0)
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    let store = Store(initialState: UserFeature.State()) {
        UserFeature()
    }
    ContentView(store: store)
}

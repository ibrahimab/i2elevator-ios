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

class SharedState: ObservableObject {
    @Published var transformationId: String? = nil
    @Published var subTransformationId: String? = nil
    @Published var cardType: String? = nil
    @Published var cardIndex: Int? = nil
    @Published var draggedSchemaItem: DraggedSchemaItem? = nil
    @Published var outputItemId: String? = nil
    @Published var userDTO: UserDTO? = nil
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
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    if self.menu == .subTransformation,
                       let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
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
                              let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
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
                              let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
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
                              let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
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
                              let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
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
                    } else if let transformations = sharedState.userDTO?.teams?["response"]?.transformations {
                        
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
                    MapRuleEditor().frame(height: geometry.size.height * 0.5 + yMovement)
                    HStack {
                        ForEach(sharedState.viewStack.indices, id: \.self) { stackItemIndex in
                            let stackItem = sharedState.viewStack[stackItemIndex]
                            if let cardType = stackItem.cardType,
                               let cardIndex = stackItem.cardIndex
                            {
                                CardView(cardIndex: cardIndex, cardType: cardType)
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
                    DraggingViewY(yMovement: $yMovement)
                        .gesture(DragGesture()
                            .onChanged { value in
                                yMovement = value.translation.height
                            }
                        )
                }
                
                FunctionCatalog().frame(width: 300 - x2Movement)
            }.onAppear {
                if let str = Bundle.main.path(forResource: "UserDTO", ofType: "plist") {
                    let d = NSDictionary(contentsOfFile: str)
                    if let d = d {
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: d, options: [])
                        else {
                            // Handle errors
                            return
                        }
                        do {
                            let jsonDecoder = JSONDecoder()
                            sharedState.userDTO = try jsonDecoder.decode(UserDTO.self, from: jsonData )
                        } catch {
                            // Handle decoding error
                            print("Decoding error: \(error)")
                        }
                    }
                }
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
                    .background(Color.green)
                    .foregroundColor(.white)
                    .gesture(DragGesture()
                        .onChanged { value in
                            x1Movement = value.translation.width
                        }
                    )
                    .position(x: 300 + x1Movement, y: 400)
                Rectangle()
                    .frame(width: 8, height: 100)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .gesture(DragGesture()
                        .onChanged { value in
                            x2Movement = value.translation.width
                        }
                    )
                    .position(x: geometry.size.width - 300 + x2Movement, y: 400)
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}

struct DraggingViewY: View {
    @Binding var yMovement: CGFloat
    
    var body: some View {
        Rectangle()
            .frame(width: 100, height: 8)
            .background(Color.green)
            .foregroundColor(.white)
            .offset(x: 0, y: yMovement)
    }
}

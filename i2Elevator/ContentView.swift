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
    //@Published var outputItemId: String? = nil
    @Published var draggedFunctionName: String? = nil
    @Published var expressionKeypathSegment: [Any]? = nil
    @Published var schemaItemsOnScratchpad: [DraggedSchemaItem] = []
    @Published var functionCategoryIndex: Int = 0
    @Published var selectedSchemaItemId: String? = nil
    @Published var selectedParentSchemaItemId: String? = nil
    
    // NOTE: Is this used?
    @Published var childSchemaItemId: String? = nil
    @Published var isFunctionCatalogCombined: Bool = true
    @Published var selectedFunctionName: String? = nil
    @Published var viewStack: [ViewDropData] = []
    @Published var viewToDrop: ViewDropData? = nil
    @Published var runTransformationReturn: [String : Any]?
    @Published var menu: SelectedMenuItem = .transformationList
    @Published var inputExpectedOutputPairId: String? = nil
}

enum SelectedMenuItem {
    case transformationList
    case transformation
    case subTransformation
    case subTransformationDetails
    case schemaItemList
    case schemaItem
    case inputExpectedOutputPair
    case tags
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
    @State private var selectedTab = 3
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selectedTab) {
                Text("Permissions")
                    .tabItem {
                        Image(systemName: "shield")
                        Text("Permissions")
                    }
                    .tag(0)
                Text("Search")
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)
                Text("Teams")
                    .tabItem {
                        Image(systemName: "person.2.square.stack")
                        Text("Teams")
                    }
                    .tag(2)
                HStack {
                    VStack {
                        if (sharedState.menu == .subTransformation || sharedState.menu == .subTransformationDetails),
                           let transformations = store.userDTO?.teams?["response"]?.transformations,
                           let transformationId = sharedState.transformationId,
                           let subTransformations = transformations[transformationId]?.subTransformations,
                           let subTransformationId = sharedState.subTransformationId,
                           let _ = subTransformations[subTransformationId]?.name
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
                                    sharedState.menu = .subTransformationDetails
                                }) {
                                    Image(systemName: "gear")
                                } .clipShape(Circle())
                            }
                            .padding(20)
                            List {
                                if let cards = subTransformations[subTransformationId]?.inputs {
                                    Section() {
                                        HStack {
                                            Text("Card in").bold()
                                            Spacer()
                                        }
                                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                        .padding()
                                        ForEach(cards.indices, id: \.self) { index in
                                            Button(action: {
                                                if sharedState.viewStack.firstIndex(where: { viewDropData in
                                                    viewDropData.cardIndex == index && viewDropData.cardType == "in"
                                                }) == nil {
                                                    let viewDropData = ViewDropData(name: "SubTransformationView", cardType: "in", cardIndex: index)
                                                    sharedState.viewStack.append(viewDropData)
                                                }
                                            }) {
                                                HStack {
                                                    Text("Card") //cards[index].name
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                }
                                            }
                                            .padding()
                                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                        }
                                    }
                                    .background(Color.init(white: 0.35))
                                }
                                if let cards = subTransformations[subTransformationId]?.outputs {
                                    Section() {
                                        HStack {
                                            Text("Card out").bold()
                                            Spacer()
                                        }
                                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                        .padding()
                                        ForEach(cards.indices, id: \.self) { index in
                                            Button(action: {
                                                if sharedState.viewStack.firstIndex(where: { viewDropData in
                                                    viewDropData.cardIndex == index && viewDropData.cardType == "out"
                                                }) == nil {
                                                    let viewDropData = ViewDropData(name: "SubTransformationView", cardType: "out", cardIndex: index)
                                                    sharedState.viewStack.append(viewDropData)
                                                }
                                            }) {
                                                HStack {
                                                    Text("Card") //cards[index].name
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                }
                                            }
                                            .padding()
                                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                        }
                                    }
                                    .background(Color.init(white: 0.35))
                                }
                            }
                            .listStyle(PlainListStyle())
                        } else if sharedState.menu == .schemaItem,
                                  let transformations = store.userDTO?.teams?["response"]?.transformations,
                                  let transformationId = sharedState.transformationId,
                                  let transformation = transformations[transformationId],
                                  let schemaItemId = sharedState.selectedSchemaItemId,
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
                            .padding(20)
                            HStack {
                                Spacer()
                                Button(action: {
                                    
                                }) {
                                    Text(schemaItem.children[childSchemaItemId] == nil ? "Remove child schema item from parent" : "Assign item to \(schemaItem.name)")
                                }
                            }
                            HStack {
                                Spacer()
                                Button(action: {
                                    
                                }) {
                                    Text("Delete child schema item")
                                }
                            }.padding(.bottom, 40)
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
                            .listStyle(PlainListStyle())
                            Spacer()
                        } else if sharedState.menu == .schemaItem,
                                  let transformations = store.userDTO?.teams?["response"]?.transformations,
                                  let transformationId = sharedState.transformationId,
                                  let transformation = transformations[transformationId],
                                  let schemaItemId = sharedState.selectedSchemaItemId,
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
                            .padding(20)
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
                            .listStyle(PlainListStyle())
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
                            .padding(20)
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
                            Spacer()
                            List {
                                Section(header: Text("\(transformation.name) > Schema Items")) {
                                    ForEach(transformation.schemaItems.keys.sorted(), id: \.self) { schemaItemId in
                                        if let schemaItem = transformation.schemaItems[schemaItemId] {
                                            Button(action: {
                                                sharedState.menu = .schemaItem
                                                self.sharedState.selectedSchemaItemId = schemaItemId
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
                            .listStyle(PlainListStyle())
                        } else if sharedState.menu == .transformation || sharedState.menu == .inputExpectedOutputPair || sharedState.menu == .tags,
                                  let transformations = store.userDTO?.teams?["response"]?.transformations,
                                  let transformationId = sharedState.transformationId,
                                  let transformation = transformations[transformationId]
                        {
                            HStack {
                                Button(action: {
                                    if sharedState.menu == .inputExpectedOutputPair || sharedState.menu == .tags {
                                        sharedState.menu = .transformation
                                    } else {
                                        sharedState.menu = .transformationList
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                }
                                .clipShape(Circle())
                                .padding(.trailing, 8)
                                Text(transformation.name)
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            List {
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
                            .listStyle(PlainListStyle())
                            .background(Color.init(white: 0.35))
                            Spacer()
                        } else if let _ = store.userDTO?.teams?["response"]?.transformations {
                            HStack {
                                Text("i2Elevator")
                                    .font(.title)
                                    .bold()
                                    .padding(.leading, 8)
                                Spacer()
                            }
                            .padding(20)
                            List {
                                Section {
                                    Button(action: {
                                        
                                    }) {
                                        HStack {
                                            Image(systemName: "clock").padding(.trailing, 8)
                                            Text("Recents").bold()
                                            Spacer()
                                        }
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .padding()
                                    Button(action: {
                                        
                                    }) {
                                        HStack {
                                            Image(systemName: "star").padding(.trailing, 8)
                                            Text("Favorites").bold()
                                            Spacer()
                                        }
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .padding()
                                }
                                .background(Color.init(white: 0.35))
                                Section {
                                    HStack {
                                        Image(systemName: "tag").padding(.trailing, 8)
                                        Text("Tags").bold()
                                        Spacer()
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .padding()
                                    //.listRowBackground(Color.init(white: 0.35))
                                    Button(action: {
                                        
                                    }) {
                                        HStack {
                                            Text("#itx")
                                            Spacer()
                                            Image(systemName: "square")
                                        }
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .padding()
                                    Button(action: {
                                        
                                    }) {
                                        HStack {
                                            Text("#tutorial")
                                            Spacer()
                                            Image(systemName: "square")
                                        }
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .padding()
                                }
                                .background(Color.init(white: 0.35))
                            }
                            .listStyle(PlainListStyle())
                            .background(Color.init(white: 0.35))
                        }
                    }
                    .frame(width: 300 + x1Movement)
                    .background(Color.init(white: 0.35))
                    if sharedState.menu == .transformationList,
                       let transformations = store.userDTO?.teams?["response"]?.transformations
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
                                let availableWidth = geometry.size.width - 300 // Subtract width of other view
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
                                                            .foregroundColor(.yellow)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                        //}
                                                    }
                                                    Spacer()
                                                }
                                                .frame(width: 300, height: 64)
                                            }
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.gray)
                                            )
                                            .buttonBorderShape(.roundedRectangle(radius: 10))
                                        }
                                    }
                                }
                                .padding()
                            }
                        }.padding()
                    } else {
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
                    }
                    if sharedState.menu != .transformationList
                    {
                        RightView(store: store).frame(width: 300 - x2Movement)
                    }
                }.overlay {
                    if sharedState.menu != .transformationList {
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
                .tabItem {
                    Image(systemName: "arrowshape.forward")
                    Text("Transformations")
                }
                .tag(3)
            }
            .onAppear {
                let url = URL(string: "\(baseUrl)/auth/me")! //https://datamapper.vercel.app/api/auth/me"
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                components.queryItems = []
                /*let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyTmFtZSI6IkrDoW5vcyIsInVzZXJJZCI6IjY2MmYzYWE2ZDdiYWEyZGY5MjExODJiNCIsImVtYWlsIjoia3Vrb2RhamFub3NAaWNsb3VkLmNvbSIsImlhdCI6MTcxODAwMTgyMiwiZXhwIjoxNzIwNTkzODIyfQ.jsxEJEyBILuqq3bOJg9mOdA5guchXj4iVXsuYUxLnJg"*/
                let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyTmFtZSI6IkrDoW5vcyIsInVzZXJJZCI6IjY2MmYzYWE2ZDdiYWEyZGY5MjExODJiNCIsImVtYWlsIjoia3Vrb2RhamFub3NAaWNsb3VkLmNvbSIsImlhdCI6MTcyMDg0MTM0MCwiZXhwIjoxNzIzNDMzMzQwfQ.6Q5Hf0g9d1PB4xpm2HpVdXoy_u5aPrSQpQ6BPNwwl4o"
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
            }
        }
    }
}


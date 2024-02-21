//
//  ContentView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct IndentedSchemaItem {
    var indentation: Int
    var schemaItemName: String
    var type: String
}

struct Card {
    var name: String
    var indentedSchemaItems: [IndentedSchemaItem]
}

struct SubTransformation {
    var name: String
    var cardsIn: [Card]
    var cardsOut: [Card]
}

struct Transformation {
    var name: String
    var subTransformations: [String: SubTransformation]
}

let cai0 = Card(name: "c-in-0", indentedSchemaItems: [IndentedSchemaItem(indentation: 0, schemaItemName: "json-unit", type: "node"),
                                                      IndentedSchemaItem(indentation: 1, schemaItemName: "json-invoice-list", type: "leaf")])

let cai1 = Card(name: "c-in-1", indentedSchemaItems: [IndentedSchemaItem(indentation: 0, schemaItemName: "json-invoice", type: "node"),
                                                      IndentedSchemaItem(indentation: 1, schemaItemName: "json-invoice-items", type: "leaf")])

let _subTransformations: [String: SubTransformation] = ["st0": SubTransformation(name: "ST0",
                                                                                 cardsIn: [cai0],
                                                                                 cardsOut: [cai0]),
                                                        "st1": SubTransformation(name: "ST1",
                                                                                 cardsIn: [cai0],
                                                                                 cardsOut: [cai0, cai1])]

let transformations: [String: Transformation] = [
    "t0": Transformation(name: "T0", subTransformations: _subTransformations),
    "t1": Transformation(name: "T1", subTransformations: _subTransformations),
    "t2": Transformation(name: "T2", subTransformations: _subTransformations),
    "t3": Transformation(name: "T3", subTransformations: _subTransformations),
    "t4": Transformation(name: "T4", subTransformations: _subTransformations),
    "t5": Transformation(name: "T5", subTransformations: _subTransformations),
    "t6": Transformation(name: "T6", subTransformations: _subTransformations),
    "t7": Transformation(name: "T7", subTransformations: _subTransformations),
    "t8": Transformation(name: "T8", subTransformations: _subTransformations),
    "t9": Transformation(name: "T9", subTransformations: _subTransformations),
    "t10": Transformation(name: "T10", subTransformations: _subTransformations),
    "t11": Transformation(name: "T11", subTransformations: _subTransformations),
    "t12": Transformation(name: "T12", subTransformations: _subTransformations),
    "t13": Transformation(name: "T13", subTransformations: _subTransformations),
    "t14": Transformation(name: "T14", subTransformations: _subTransformations),
    "t15": Transformation(name: "T15", subTransformations: _subTransformations),
    "t16": Transformation(name: "T16", subTransformations: _subTransformations),
    "t17": Transformation(name: "T17", subTransformations: _subTransformations),
    "t18": Transformation(name: "T18", subTransformations: _subTransformations),
    "t19": Transformation(name: "T19", subTransformations: _subTransformations)
]

class SharedState: ObservableObject {
    @Published var transformationId: String? = nil
    @Published var subTransformationId: String? = nil
}

enum SelectedMenuItem {
    case none
    case subTransformation
    case transformation
}

struct ContentView: View {
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.openWindow) private var openWindow
    
    @State private var menu: SelectedMenuItem = .none
    
    var body: some View {
        ZStack {
            TopColorGradient(color: .red)
            if self.menu == .subTransformation,
               let transformationId = sharedState.transformationId,
               let subTransformations = transformations[transformationId]?.subTransformations,
               let subTransformationId = sharedState.subTransformationId,
               let subTransformationName = subTransformations[subTransformationId]?.name
            {
                VStack {
                    HStack {
                        Button(action: {
                            self.menu = .transformation
                        }) {
                            Text("Back").foregroundColor(Color.primary)
                        }
                        Spacer()
                    }.padding()
                    Spacer()
                    Text("\(subTransformationName)")
                    List {
                        if let cards = subTransformations[subTransformationId]?.cardsIn {
                            Section(header: Text("Card In")) {
                                ForEach(cards.indices, id: \.self) { index in
                                    HStack {
                                        Text(cards[index].name)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .contentShape(Rectangle()) 
                                    .onTapGesture {
                                        openWindow(id: "SubTransformationView", value: MyData(intValue: index, stringValue: "in"))
                                    }
                                }
                            }
                        }
                        if let cards = subTransformations[subTransformationId]?.cardsOut {
                            Section(header: Text("Card Out")) {
                                ForEach(cards.indices, id: \.self) { index in
                                    HStack {
                                        Text(cards[index].name)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .contentShape(Rectangle()) 
                                    .onTapGesture {
                                        openWindow(id: "SubTransformationView", value: MyData(intValue: index, stringValue: "out"))
                                    }
                                }
                            }
                        }
                    }
                }.padding()
            } else if self.menu == .transformation,
                      let transformationId = sharedState.transformationId,
                      let transformation = transformations[transformationId]
            {
                VStack {
                    HStack {
                        Button(action: {
                            self.menu = .none
                        }) {
                            Text("Back").foregroundColor(Color.primary)
                        }
                        Spacer()
                    }.padding()
                    Spacer()
                    List {
                        Section(header: Text("\(transformation.name) > Sub Transformations")) {
                            ForEach(transformation.subTransformations.keys.sorted(), id: \.self) { subTransformationId in
                                if let subTransformation = transformation.subTransformations[subTransformationId] {
                                    HStack {
                                        Text(subTransformation.name)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        self.menu = .subTransformation
                                        self.sharedState.subTransformationId = subTransformationId
                                    }
                                }
                            }
                        }
                    }
                }.padding()
            } else {
                List {
                    Section(header: Text("Transformations")) {
                        ForEach(transformations.keys.sorted(), id: \.self) { transformationId in
                            if let transformation = transformations[transformationId] {
                                HStack {
                                    Text(transformation.name)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .contentShape(Rectangle()) 
                                .onTapGesture {
                                    self.sharedState.transformationId = transformationId
                                    self.menu = .transformation
                                }
                            }
                        }
                    }
                }.padding()
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}

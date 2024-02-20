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

let cai0 = Card(name: "c-in-0", indentedSchemaItems: [IndentedSchemaItem(indentation: 0, schemaItemName: "json-unit"),
                                                     IndentedSchemaItem(indentation: 1, schemaItemName: "json-invoice-list")])

let cai1 = Card(name: "c-in-1", indentedSchemaItems: [IndentedSchemaItem(indentation: 0, schemaItemName: "json-invoice"),
                                                     IndentedSchemaItem(indentation: 1, schemaItemName: "json-invoice-items")])

let subTransformations: [String: SubTransformation] = ["st0": SubTransformation(name: "ST0",
                                                                                cardsIn: [cai0],
                                                                                cardsOut: [cai0]),
                                                       "st1": SubTransformation(name: "ST1",
                                                                                cardsIn: [cai0],
                                                                                cardsOut: [cai0, cai1])]

class SharedState: ObservableObject {
    @Published var subTransformationId: String? = nil
}

struct ContentView: View {
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if let subTransformationId = sharedState.subTransformationId,
           let subTransformationName = subTransformations[subTransformationId]?.name
        {
            VStack {
                HStack {
                    Button(action: {
                        self.sharedState.subTransformationId = nil
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
                                .contentShape(Rectangle()) // Ensure the entire HStack is tappable
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
                                .contentShape(Rectangle()) // Ensure the entire HStack is tappable
                                .onTapGesture {
                                    openWindow(id: "SubTransformationView", value: MyData(intValue: index, stringValue: "out"))
                                }
                            }
                        }
                    }
                }
            }.padding()
        } else {
            List {
                Section(header: Text("SubTransformations")) {
                    ForEach(subTransformations.keys.sorted(), id: \.self) { key in
                        if let value = subTransformations[key] {
                            HStack {
                                Text(value.name).foregroundColor(Color.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .contentShape(Rectangle()) // Ensure the entire HStack is tappable
                            .onTapGesture {
                                self.sharedState.subTransformationId = key
                            }
                        }
                    }
                }
            }.padding()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}

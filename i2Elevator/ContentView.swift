//
//  ContentView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

let subTransformations: [String: (name: String, cards: [String])] = [
    "st0": (name: "ST0", cards: ["C00", "C01"]),
    "st1": (name: "ST1", cards: ["C1A", "C1B", "C1C"]),
    "st2": (name: "ST2", cards: ["C2X", "C2Y", "C2Z"])
]

class SharedState: ObservableObject {
    @Published var subTransformationId: String? = nil
}

struct ContentView: View {
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if let subTransformationId = sharedState.subTransformationId,
           let subTransformationName = subTransformations[subTransformationId]?.name,
           let cards = subTransformations[subTransformationId]?.cards
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
                List {
                    Section(header: Text("\(subTransformationName) > Card In")) {
                        ForEach(cards.indices, id: \.self) { index in
                            HStack {
                                Text(cards[index]).foregroundColor(Color.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .contentShape(Rectangle()) // Ensure the entire HStack is tappable
                            .onTapGesture {
                                openWindow(id: "SubTransformationView", value: index)
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

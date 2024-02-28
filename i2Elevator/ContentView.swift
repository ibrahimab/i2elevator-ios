//
//  ContentView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

class SharedState: ObservableObject {
    @Published var transformationId: String? = nil
    @Published var subTransformationId: String? = nil
    @Published var inputItemId: String? = nil
    @Published var outputItemId: String? = nil
    @Published var userDTO: UserDTO? = nil
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
               let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
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
                        if let cards = subTransformations[subTransformationId]?.inputs {
                            Section(header: Text("Card In")) {
                                ForEach(cards.indices, id: \.self) { index in
                                    Button(action: {
                                        openWindow(id: "SubTransformationView", value: MyData(intValue: index, stringValue: "in"))
                                    }) {
                                        HStack {
                                            Text(cards[index].name)
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
                                        openWindow(id: "SubTransformationView", value: MyData(intValue: index, stringValue: "out"))
                                    }) {
                                        HStack {
                                            Text(cards[index].name)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.padding()
            } else if self.menu == .transformation,
                      let transformations = sharedState.userDTO?.teams?["response"]?.transformations,
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
                    }
                }.padding()
            } else if let transformations = sharedState.userDTO?.teams?["response"]?.transformations {
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
                }.padding()
            }
        }.onAppear {
            let ll = Bundle(path: "UserDTO")
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
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}

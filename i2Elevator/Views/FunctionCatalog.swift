//
//  FunctionCatalog.swift
//  i2Elevator
//
//  Created by János Kukoda on 07/03/2024.
//

import SwiftUI

struct FunctionCatalog: View {
    @EnvironmentObject var sharedState: SharedState
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ZStack {
            TopColorGradient(color: .cyan)
            VStack {
                /*HStack {
                    Button(action: {
                        
                    }) {
                        Text("Function Catalog")
                    }.onDrag {
                        sharedState.viewToDrop = ViewDropData(name: "FunctionCatalog")
                        let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                        return itemProvider
                    }
                    Button(action: {
                        if let i = sharedState.viewStack.firstIndex(where: { aa in
                            aa.name == "FunctionCatalog"
                        }) {
                            sharedState.viewStack.remove(at: i)
                            openWindow(id: "FunctionCatalog")
                        }
                    }) {
                        Image(systemName: "lanyardcard")
                    }.clipShape(Circle())
                }*/
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
                Spacer()
            }.padding()
        }
    }
}

struct FunctionCatalogContainer: View {
    @EnvironmentObject var sharedState: SharedState
    var body: some View {
        ZStack {
            TopColorGradient(color: .cyan)
            TabView(selection: $sharedState.functionCategoryIndex) {
                ForEach(signatureCategories.indices, id: \.self) { index in
                    FunctionCatalog()
                        .tabItem {
                            Label(signatureCategories[index].name, systemImage: signatureCategories[index].tabItemImage)
                        }
                }
            }
        }
    }
}

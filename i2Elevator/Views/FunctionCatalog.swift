//
//  FunctionCatalog.swift
//  i2Elevator
//
//  Created by János Kukoda on 07/03/2024.
//

import SwiftUI

struct FunctionCatalog: View {
    @EnvironmentObject var sharedState: SharedState
    var body: some View {
        if let selectedFunctionName = sharedState.selectedFunctionName {
            VStack {
                Text("\(selectedFunctionName): Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.")
                Spacer()
            }.padding()
        }
        /*List {
            ForEach(Array(functionPropsTypes[sharedState.functionCategoryIndex].functions.keys.sorted()), id: \.self) { key in
                Button(action: {
                    
                }) {
                    Text(key)
                }.onDrag {
                    resetDragProperties()
                    sharedState.draggedFunctionName = key
                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                    return itemProvider
                }
            }
        }.padding(.vertical, 40)*/
    }
}

struct FunctionCatalogContainer: View {
    @EnvironmentObject var sharedState: SharedState
    var body: some View {
        ZStack {
            TopColorGradient(color: .cyan)
            TabView(selection: $sharedState.functionCategoryIndex) {
                ForEach(functionPropsTypes.indices, id: \.self) { index in
                    FunctionCatalog()
                        .tabItem {
                            Label(functionPropsTypes[index].name, systemImage: functionPropsTypes[index].tabItemImage)
                        }
                }
            }
        }
    }
}

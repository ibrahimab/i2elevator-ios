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
        VStack {
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

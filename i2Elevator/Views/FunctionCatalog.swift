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
        ZStack {
            TopColorGradient(color: .cyan)
            List {
                Button(action: {
                    
                }) {
                    Text("UPPERCASE")
                }.onDrag {
                    resetDragProperties()
                    sharedState.newFunctionName = "UPPERCASE"
                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                    return itemProvider
                }
                Button(action: {
                    
                }) {
                    Text("LOWERCASE")
                }.onDrag {
                    resetDragProperties()
                    sharedState.newFunctionName = "LOWERCASE"
                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                    return itemProvider
                }
                Button(action: {
                    
                }) {
                    Text("LOOKUP")
                }.onDrag {
                    resetDragProperties()
                    sharedState.newFunctionName = "LOOKUP"
                    let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                    return itemProvider
                }
            }
            .padding(.vertical, 40)
        }
    }
}

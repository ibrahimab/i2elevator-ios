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
                ForEach(Array(functionPropsTypes.keys.sorted()), id: \.self) { key in
                    Button(action: {
                        
                    }) {
                        Text(key)
                    }.onDrag {
                        resetDragProperties()
                        sharedState.newFunctionName = key
                        let itemProvider = NSItemProvider(object: "YourDraggedData" as NSItemProviderWriting)
                        return itemProvider
                    }
                }
            }
            .padding(.vertical, 40)
        }
    }
}

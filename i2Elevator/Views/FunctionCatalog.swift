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
                    Text("Uppercase")
                }
                Button(action: {
                    
                }) {
                    Text("Lowercase")
                }
                Button(action: {
                    
                }) {
                    Text("Lookup")
                }
            }
            .padding(.vertical, 40)
        }
    }
}

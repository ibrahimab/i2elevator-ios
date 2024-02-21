//
//  TopColorGradient.swift
//  i2Elevator
//
//  Created by János Kukoda on 21/02/2024.
//

import SwiftUI

struct TopColorGradient: View {
    var color : Color
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [color.opacity(0.6), color.opacity(0.3), Color.primary.opacity(0.3), Color.primary.opacity(0.3), Color.primary.opacity(0.1), Color.primary.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
        
    }
}

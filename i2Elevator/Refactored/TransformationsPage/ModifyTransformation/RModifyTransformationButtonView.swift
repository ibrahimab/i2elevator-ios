//
//  CreateTransformationButtonView.swift
//  i2Elevator
//
import SwiftUI

struct RCreateTransformationButtonView: View {
    var body: some View {
        HStack {
            Spacer()
            Button(action: {}, label: {
                Text("Create Transformation")
            })
            .buttonStyle(BorderedButtonStyle())
        }
    }
}

#Preview {
    RCreateTransformationButtonView()
}

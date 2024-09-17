//
//  InputExpectedOutputPairView.swift
//  i2Elevator
//

import SwiftUI
import ComposableArchitecture

struct RInputExpectedOutputPairView: View {
    let label: String
    let checked: Bool
    var body: some View {
        Button(action: {}) {
            HStack {
                Text("\(label)")
                Spacer()
                if checked == true {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
                Image(systemName: "chevron.right").padding(.leading, 8)
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .padding()
    }
}

#Preview("[RInputExpectedOutputPairView] InputExpectedOutputPairView with a label and checked being false") {
    RInputExpectedOutputPairView(label: "43ff", checked: false)
}


#Preview("[RInputExpectedOutputPairView] InputExpectedOutputPairView with a label and checked being true") {
    RInputExpectedOutputPairView(label: "5jng", checked: true)
}

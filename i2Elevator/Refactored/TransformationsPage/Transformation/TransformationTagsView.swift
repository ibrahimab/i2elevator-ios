//
//  TransformationTagView.swift
//  i2Elevator
//
import SwiftUI

struct TransformationTagsView: View {
    let tags: [String]
    var body: some View {
        Text(tags.map { "#\($0)" }.joined(separator: " ")) //tags
            .font(.caption)
            .foregroundColor(.green)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TransformationTagsView(tags: ["itx", "tutorial"])
}

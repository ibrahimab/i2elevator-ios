//
//  TransformationListItemView.swift
//  i2Elevator
//
import SwiftUI

struct RTransformationListItemView: View {
    let transformation: RTransformation
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "circle.hexagonpath")
                    .padding()
                VStack {
                    Text(transformation.name)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        TransformationTagsView(tags: transformation.tags)
                }
                Spacer()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.11))
        )
        .buttonBorderShape(.roundedRectangle(radius: 10))
    }
}

#Preview("[TransformationListItemView] Without tags provided") {
    RTransformationListItemView(transformation:
        RTransformation(id: UUID(), name: "No tags provided, showing default tags")
    )
}

#Preview("[TransformationListItemView] With tags provided") {
    RTransformationListItemView(transformation:
        RTransformation(id: UUID(), name: "Tags provided, show them", tags: ["tag", "this"])
    )
}

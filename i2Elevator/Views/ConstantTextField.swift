//
//  ConstantTextField.swift
//  i2Elevator
//
//  Created by János Kukoda on 05/06/2024.
//

import SwiftUI
import ComposableArchitecture

struct ConstantTextField: View {
    @EnvironmentObject var sharedState: SharedState
    let store: StoreOf<UserFeature>
    @State private var text: String
    @State private var isEditing: Bool = false
    
    let transformationId: String
    let subTransformationId: String
    let cardIndex: Int
    let outputItemId: String
    let column: ExpressionColumn
    
    init(store: StoreOf<UserFeature>, transformationId: String, subTransformationId: String, cardIndex: Int, outputItemId: String, column: ExpressionColumn) {
        self.store = store
        self.transformationId = transformationId
        self.subTransformationId = subTransformationId
        self.cardIndex = cardIndex
        self.outputItemId = outputItemId
        self.column = column
        self._text = State(initialValue: column.text)
    }
    
    var body: some View {
        TextField("constant", text: $text, onEditingChanged: { editing in
            self.isEditing = editing
            if !editing {
                // Text field is closed, perform any necessary actions here
                let value = ["type": "constant", "constant": text]
                let keyPath: [Any] = ["response", "transformations", transformationId, "subTransformations", subTransformationId, "outputs", cardIndex, "mapRules", outputItemId, "objectrule"] + column.expressionKeypathSegment
                store.send(.setValue(keyPath: keyPath, value: value))
            }
        })
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
    }
}

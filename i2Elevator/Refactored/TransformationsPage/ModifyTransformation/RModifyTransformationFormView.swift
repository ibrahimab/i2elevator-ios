//
//  CreateTransformationFormView.swift
//  i2Elevator
//
import SwiftUI
import ComposableArchitecture

struct RModifyTransformationFormView: View {
    @Bindable var store: StoreOf<RModifyTransformationFeature>
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                Section(header: Text("Transformation Name")) {
                    TextField("Enter Transformation Name", text: $store.transformation.name.sending(\.setName))
                }
                Section() {
                    Button(action: {}) {
                        Text("Create input - expected output pair")
                    }
                    Button(action: {}) {
                        Text("Delete transformation")
                    }
                }
                Section(header: Text("External TypeTree updated at")) {
                    Text("")
                    Button(action: {}) {
                        Text("Import external xml typetree")
                    }
                }
                Section(header: Text("External Transformation updated at")) {
                    Text("")
                    Button(action: {}) {
                        Text("Import external xml transformation")
                    }
                }
                Section(header: Text("Input - Expected Output Pairs")) {
                    if let inputExpectedOutputTextIdPairs = store.transformation.inputExpectedOutputTextIdPairs {
                        ForEach(Array(inputExpectedOutputTextIdPairs.keys.sorted()), id: \.self) { key in
                            // @TODO making checked dynamic based on data
                            RInputExpectedOutputPairView(label: key, checked: false)
                        }
                    }
                }
                Section(header: Text("Tags")) {
                    HStack {
                        TransformationTagsView(tags: store.transformation.tags)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RModifyTransformationFormView(
        store: Store(
            initialState: RModifyTransformationFeature.State(
                transformation: RTransformation(id: UUID(), name: "")
            )
        ) {
            RModifyTransformationFeature()
        }
    )
}

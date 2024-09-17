//
//  TransformationsPageFeature.swift
//  i2Elevator
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct RTransformationsPageFeature {
    @ObservableState
    struct State: Equatable {
        var transformations = RTransformationListFeature.State()
    }
    enum Action {
        case createTransformation
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .createTransformation:
                return .none
            }
        }
    }
}

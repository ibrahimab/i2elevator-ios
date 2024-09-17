//
//  RCreateTransformationFeature.swift
//  i2Elevator
//
import Foundation
import ComposableArchitecture

@Reducer
struct RModifyTransformationFeature {
    // @TODO: refactor this to use the common RTransformation struct rather than this manual struct
    @ObservableState
    struct State: Equatable {
        var transformation: RTransformation
    }
    enum Action {
        case setName(String)
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setName(name):
                state.transformation.name = name
                return .none
            }
        }
    }
}

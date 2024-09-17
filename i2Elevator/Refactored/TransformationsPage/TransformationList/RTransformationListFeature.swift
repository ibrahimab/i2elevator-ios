//
//  TransformationListFeature.swift
//  i2Elevator
//
import Foundation
import ComposableArchitecture

@Reducer
struct RTransformationListFeature {
    @ObservableState
    struct State: Equatable {
        var transformations: IdentifiedArrayOf<RTransformation> = []
    }
}

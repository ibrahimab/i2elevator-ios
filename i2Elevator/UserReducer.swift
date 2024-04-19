//
//  UserReducer.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/04/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct UserFeature {
    @ObservableState
    struct State {
        var userDTO: UserDTO? = nil
    }
    enum Action {
        case initialize(userDTO: UserDTO)
        case setValue(keyPath: [Any], value: Any?)
        case removeKey(keyPath: [Any])
    }
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .initialize(userDTO):
                state.userDTO = userDTO
                return .none
            case let .setValue(keyPath, value):
                state.userDTO = updateClient(userDTO: state.userDTO, value: value, keyPath: keyPath, operation: "setValue")
                return .none
            case let .removeKey(keyPath):
                state.userDTO = updateClient(userDTO: state.userDTO, value: nil, keyPath: keyPath, operation: "removeKey")
                return .none
            }
        }
    }
}

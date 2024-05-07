//
//  i2ElevatorApp.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI
import ComposableArchitecture

struct MyData: Codable, Hashable {
    var intValue: Int
    var stringValue: String
}

struct CardSettingsData: Codable, Hashable {
    var intValue: Int
    var stringValue: String
}

@main
struct i2ElevatorApp: App {
    let sharedState = SharedState()
    let store = Store(initialState: UserFeature.State()) {
        UserFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store).environmentObject(sharedState).preferredColorScheme(.dark)
        }
    }
}

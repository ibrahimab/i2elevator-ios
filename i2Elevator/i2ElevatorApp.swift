//
//  i2ElevatorApp.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI

@main
struct i2ElevatorApp: App {
    private var size : CGSize = CGSize(width: 400, height: 600)
    let sharedState = SharedState()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(sharedState)
        }.defaultSize(size)
        WindowGroup(id: "SubTransformationView", for: Int.self) { $index in CardView(cardIndex: index ?? 0).environmentObject(sharedState)
        }
    }
}

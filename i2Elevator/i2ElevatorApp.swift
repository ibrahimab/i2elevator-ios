//
//  i2ElevatorApp.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI

struct MyData: Codable, Hashable {
    var intValue: Int
    var stringValue: String
}

@main
struct i2ElevatorApp: App {
    private var portraitSize : CGSize = CGSize(width: 400, height: 600)
    private var landscapeSize : CGSize = CGSize(width: 600, height: 400)
    let sharedState = SharedState()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(sharedState)
        }.defaultSize(portraitSize)
        WindowGroup(id: "SubTransformationView", for: MyData.self) { data in
            if let data = data.wrappedValue {
                CardView(cardIndex: data.intValue, cardType: data.stringValue)
                    .environmentObject(sharedState)
            } else {
                EmptyView()
            }
        }.defaultSize(portraitSize)
        WindowGroup("MapRuleEditor", id: "MapRuleEditor") {
            MapRuleEditor().environmentObject(sharedState)
        }.defaultSize(landscapeSize)
        WindowGroup("FunctionCatalog", id: "FunctionCatalog") {
            FunctionCatalog().environmentObject(sharedState)
        }.defaultSize(portraitSize)
    }
}

//
//  CardView.swift
//  i2Elevator
//
//  Created by János Kukoda on 19/02/2024.
//

import SwiftUI

struct CardView: View {
    var cardIndex: Int
    @EnvironmentObject var sharedState: SharedState
    var body: some View {
        if let subTransformationId = sharedState.subTransformationId,
           let c = subTransformations[subTransformationId]?.cards.count,
            cardIndex < c,
           let cardName = subTransformations[subTransformationId]?.cards[cardIndex]
        {
            Text("Opened: \(cardName)")
        }
    }
}

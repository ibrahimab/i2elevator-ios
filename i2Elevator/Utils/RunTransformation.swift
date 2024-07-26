//
//  RunTransformation.swift
//  i2Elevator
//
//  Created by János Kukoda on 20/06/2024.
//

import SwiftUI
import ComposableArchitecture

func runTransformation(transformationId: String, sharedState: SharedState, store: StoreOf<UserFeature>) {
    let url = URL(string: "\(baseUrl)/transform")!
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    components.queryItems = [
        URLQueryItem(name: "transformationId", value: transformationId)
    ]
    var request = URLRequest(url: components.url!)
    request.httpMethod = "POST"
    request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
    
    // sharedState.userDTO?.teams?["response"]?.transformations[transformationId]?.subTransformations[subTransformationInd]
    let inputExpectedOutputPairId = sharedState.inputExpectedOutputPairId ?? store.userDTO?.teams?["response"]?.transformations[transformationId]?.inputExpectedOutputTextIdPairs?.first?.key
    
    var text: String? = nil
    if let inputExpectedOutputPairId = inputExpectedOutputPairId {
        let tid = store.userDTO?.teams?["response"]?.transformations[transformationId]?.inputExpectedOutputTextIdPairs?[inputExpectedOutputPairId]?.inputTextId
        if let tid = tid {
            text = store.userDTO?.teams?["response"]?.texts?[tid]
        }
        if var mutableText = text, !mutableText.isEmpty {
            mutableText.removeFirst()
            text = mutableText
        }
    }
    if let text = text {
        request.httpBody = text.data(using: .utf8)
    }

        
    //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        do {
            if let data = data {
                if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        // Access your dictionary data here
                        print(jsonDictionary)
                        sharedState.runTransformationReturn = jsonDictionary
                    }
                }
            }
        } catch {
            // Handle the error here
            print("Error: \(error)")
        }
    }
    task.resume()
}

//
//  UpdateServer.swift
//  i2Elevator
//
//  Created by János Kukoda on 18/04/2024.
//


import Foundation

let baseUrl = "https://i2elevator.nl/api"

//"https://i2elevator.nl/api"
//"http://localhost:3000/api"

func updateServer(value: Any?, keyPath: [Any], operation: String) {
    let parameters: [String: Any] = [
        "value": value,
        "keyPath": keyPath,
        "operation": operation,
        "version": 2
    ]
    guard let url = URL(string: "\(baseUrl)/update") else {
        print("Invalid URL")
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Handle the response from the server
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data {
                print("Response data: \(data)")
            }
        }
        task.resume()
    } catch {
        print("Error serializing parameters: \(error)")
        // Handle the error appropriately
    }
}

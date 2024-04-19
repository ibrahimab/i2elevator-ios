//
//  UpdateClient.swift
//  i2Elevator
//
//  Created by János Kukoda on 23/02/2024.
//


import Foundation
import ComposableArchitecture

func updateClient(userDTO: UserDTO?, value: Any?, keyPath: [Any], operation: String) -> UserDTO? {
    guard let userDTO = userDTO else {
        return nil
    }
    updateServer(value: value, keyPath: keyPath, operation: operation)
    let jsonEncoder = JSONEncoder()
    guard let jsonData = try? jsonEncoder.encode(userDTO),
          let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else
    {
        return nil
    }
    if let jsonString = String(data: jsonData, encoding: .utf8) {
        print("JSON data: \(jsonString)")
    }
    let _keyPath = ["teams"] + keyPath
    let updatedDictionary = updateNode(node: dictionary, value: value, keyPath: _keyPath, operation: operation)
    let jsonDecoder = JSONDecoder()
    guard let jsonData = try? JSONSerialization.data(withJSONObject: updatedDictionary, options: [])
    else {
        // Handle errors
        return nil
    }
    do {
        return try jsonDecoder.decode(UserDTO.self, from: jsonData )
    } catch {
        // Handle decoding error
        print("Decoding error: \(error)")
        return nil
    }
}

func updateNode(node: Any, value: Any?, keyPath: [Any], operation: String) -> Any {
    if keyPath.count == 0 {
        return value ?? node
    } else {
        var keyPathWithoutFirst = keyPath
        let key = keyPathWithoutFirst.removeFirst()
        if keyPath.count > 1 {
            if let key = key as? String, var node = node as? [String: Any] {
                var nodeContent: Any
                if let _nodeContent = node[key] as? [String: Any] {
                    nodeContent = _nodeContent
                } else if let _nodeContent = node[key] as? [Any] {
                    nodeContent = _nodeContent
                } else if keyPath[1] is String {
                    nodeContent = [:]
                } else {
                    nodeContent = []
                }
                let nodeUpdatedContent = updateNode(node: nodeContent, value: value, keyPath: keyPathWithoutFirst, operation: operation)
                node[key] = nodeUpdatedContent
                return node
            } else if let ind = key as? Int, var node = node as? [Any], (ind < node.count || ind == 0) {
                var nodeContent: Any = []
                if ind < node.count {
                    nodeContent = node[ind]
                } else {
                    if keyPath[1] is String {
                        nodeContent = [:]
                    } else {
                        nodeContent = []
                    }
                }
                let nodeUpdatedContent = updateNode(node: nodeContent, value: value, keyPath: keyPathWithoutFirst, operation: operation)
                if ind < node.count {
                    node[ind] = nodeUpdatedContent
                } else {
                    node.append(nodeUpdatedContent)
                }
                return node
            } else {
                
                //print("Warning, node object is not compatible. value: \(value ?? "n/a"), key: \(key)")
                //fflush(stdout)
                return node
            }
        } else { // keyPath.count == 1
            if operation == "setValue", var node = node as? [String: Any], let key = key as? String {
                node[key] = value
                return node
            } else if operation == "setValue", var node = node as? [Any], let key = key as? Int, let value = value {
                if key == 0 && node.isEmpty {
                    node.append(value)
                } else if key == node.count {
                    node.append(value)
                } else {
                    node[key] = value
                }
                return node
            } else if operation == "removeKey", var node = node as? [String: Any], let key = key as? String {
                node[key] = nil
                return node
            } else if operation == "removeKey", var node = node as? [Any], let ind = key as? Int, ind < node.count {
                node.remove(at: ind)
                return node
            } else if operation == "push", let value = value {
                if var node = node as? [String: Any], let key = key as? String, var a = node[key] as? [Any] {
                    a.append(value)
                    node[key] = a
                    return node
                } else if var node = node as? [Any], let i = key as? Int, var a = node[i] as? [Any] {
                    a.append(value)
                    node[i] = a
                    return node
                } else {
                    print("Warning, no input found for push. value: \(value), key: \(key)")
                    //fflush(stdout)
                    return node
                }
            } else if operation == "pop", var a = node as? [Any], a.count > 0 {
                a.removeLast()
                return a
            } else if operation == "replace", let value = value as? String, var node = node as? [String: Any], let key = key as? String {
                // Same name would fully remove
                if value != key, node[key] != nil {
                    node[value] = node[key]
                    node[key] = nil
                } else if value == key {
                    print("Source and destination key are the same. Remove content like this is not possible. value: \(value), key: \(key)")
                    //fflush(stdout)
                } else if node[key] == nil {
                    print("Previous dictionary does not exist. Someone might changed it before. key: \(key), node: \(node)")
                    //fflush(stdout)
                }
                return node
            } else {
                print("Warning, no leaf update operation executed. value: \(value ?? "n/a"), key: \(key)")
                //fflush(stdout)
                return node
            }
        }
    }
}

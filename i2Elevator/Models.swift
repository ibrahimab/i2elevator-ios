//
//  Models.swift
//  i2Elevator
//
//  Created by János Kukoda on 26/02/2024.
//

import Foundation

struct UserDTO: Codable {
    var teams: [String: TeamDTO]?
}

struct TeamDTO: Codable {
    var transformations: [String: Transformation]
}

struct Transformation: Codable {
    var name: String
    var subTransformations: [String: SubTransformation]
    var schemaItems: [String: SchemaItem]
}

struct SchemaItem: Codable {
    var name: String
}

struct SubTransformation: Codable {
    var name: String
    var inputs: [Card]
    var outputs: [Card]
}

struct Card: Codable {
    var name: String
    var schemaItemId: String?
    var indentedSchemaItems: [IndentedSchemaItem]
    var mapRules: [String: String]
}

struct IndentedSchemaItem: Codable {
    var indentation: Int
    var type: String
    var schemaItemId: String
}

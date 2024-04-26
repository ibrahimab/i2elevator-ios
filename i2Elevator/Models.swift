//
//  Models.swift
//  i2Elevator
//
//  Created by János Kukoda on 26/02/2024.
//

import Foundation

struct AuthResponse: Codable {
    var message: String?
    var data: UserDTO?
}

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
    var children: [String: SchemaItemRelationship]
    var initiator: String?
    var terminator: String?
    var delimiter: String?
    var type: String?
}

public class SchemaItemRelationship: Codable {
    var rangeMax: String
}

struct SubTransformation: Codable {
    var name: String
    var inputs: [Card]
    var outputs: [Card]
}

struct Card: Codable {
    var schemaItemId: String?
    var mapRules: [String: MapRule]?
}

struct MapRule: Codable {
    var objectrule: Expression?
    var subTransformationId: String?
}

struct Expression: Codable {
    var type: String?
    var function: Function?
    var reference: String?
    var rangeMax: String?
    var constant: String?
}

struct Function: Codable  {
    var name: String
    var props: [Expression]
}

struct IndentedSchemaItem: Identifiable {
    var indentation: Int
    var numOfChildren: Int
    var schemaItemId: String
    var rangeMax: String?
    var id: String {
        schemaItemId
    }
    var disable: Bool
}

struct DraggedSchemaItem: Identifiable {
    var schemaItemId: String
    var rangeMax: String?
    var numOfChildren: Int
    var id: String {
        schemaItemId
    }
}

var signatureCategories: [SignatureCategory] = []

struct SignatureCategory: Codable {
    var name: String
    var description: String?
    var tabItemImage: String
    var functions: [String: [[SignatureItemVariation]]]
    var id: String {
        name
    }
}

struct SignatureItemVariation: Codable {
    var type: String
    var rangeMax: String?
    var id: String {
        type
    }
}

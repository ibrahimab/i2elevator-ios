//
//  Transformation.swift
//  i2Elevator
//
import Foundation

struct RTransformation: Equatable, Identifiable {
    let id: UUID
    var name: String
    var tags: [String] = ["itx", "tutorial"]
    var inputExpectedOutputTextIdPairs: [String: RInputExpectedOutputTextIdPair]?
}

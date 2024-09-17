//
//  RInputExpectedOutputTextIdPair.swift
//  i2Elevator
//
import Foundation

struct RInputExpectedOutputTextIdPair: Equatable, Identifiable {
    let id: UUID
    var inputTextId: String?
    var expectedOutputTextId: String?
}

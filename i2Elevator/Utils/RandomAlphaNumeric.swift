//
//  RandomAlphaNumeric.swift
//  i2Elevator
//
//  Created by János Kukoda on 04/03/2024.
//

func randomAlphaNumeric(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

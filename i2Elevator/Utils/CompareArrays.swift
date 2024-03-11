//
//  CompareArrays.swift
//  i2Elevator
//
//  Created by János Kukoda on 11/03/2024.
//

func compareArrays<T>(_ array1: [T], _ array2: [T]) -> Bool {
    // Check if the arrays have the same count
    guard array1.count == array2.count else {
        return false
    }

    // Iterate through the arrays and compare elements
    for (element1, element2) in zip(array1, array2) {
        // Check if the elements are both strings or both integers
        if let string1 = element1 as? String, let string2 = element2 as? String {
            guard string1 == string2 else {
                return false
            }
        } else if let int1 = element1 as? Int, let int2 = element2 as? Int {
            guard int1 == int2 else {
                return false
            }
        } else {
            // Elements are not both strings or both integers
            return false
        }
    }

    // Arrays are equal element by element
    return true
}

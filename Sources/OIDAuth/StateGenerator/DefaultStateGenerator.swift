//
//  DefaultStateGenerator.swift
//
//
//  Created by Nicholas Mata on 9/6/23.
//

import Foundation

public class DefaultStateGenerator: StateGenerator {
    public init() {}

    public func generate() -> String {
        return NSUUID().uuidString
    }
}

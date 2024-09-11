//
//  Configurable.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation

public struct Configurable {}

extension Configurable {
    func changing<T>(path: WritableKeyPath<Self, T>, to value: T) -> Self {
        var clone = self
        clone[keyPath: path] = value
        return clone
    }
}

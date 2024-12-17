//
//  Dictionary+Extensions.swift
//
//
//  Created by Disman Dmitry on 26.02.2024.
//

import Foundation

extension Dictionary where Value: RangeReplaceableCollection {
    
    @discardableResult
    public mutating func append(element: Value.Iterator.Element, toValueOfKey key: Key) -> Value? {
        
        var value: Value = self[key, default: .init()]
        value.append(element)
        self[key] = value
        return value
    }
}

//
//  KeyedDecodingContainer+decodeWrapper.swift
//
//
//  Created by Andryusina Nataly on 15.07.2024.
//

import Foundation

extension KeyedDecodingContainer {
    func decodeWrapper<T:Decodable>(
        _ type: T.Type,
        forKey key: Key,
        defaultValue: T
    ) throws -> T {
        try decodeIfPresent(type, forKey: key) ?? defaultValue
    }
}

//
//  Collection+Extensions.swift
//
//
//  Created by Disman Dmitry on 26.02.2024.
//

import Foundation

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

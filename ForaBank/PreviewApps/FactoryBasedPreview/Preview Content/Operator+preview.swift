//
//  Operator+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

import Foundation

extension Operator {
    
    static let preview: Self = .init(id: UUID().uuidString)
    static let single: Self = .init(id: "single")
    static let multiple: Self = .init(id: "multiple")
}

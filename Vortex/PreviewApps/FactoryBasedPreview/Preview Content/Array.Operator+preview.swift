//
//  Array.Operator+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import Foundation

extension Array where Element == Operator {
    
    static var preview: Self {
        
        (0..<30).map { _ in
        
                .init(id: UUID().uuidString)
        }
    }
}

//
//  Array.LastPayment+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import Foundation

extension Array where Element == LastPayment {
    
    static var preview: Self {
        
        (0..<10).map { _ in
        
                .init(id: UUID().uuidString)
        }
    }
}

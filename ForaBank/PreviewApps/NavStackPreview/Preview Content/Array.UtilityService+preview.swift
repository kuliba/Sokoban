//
//  Array.UtilityService+preview.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import Foundation

extension Array where Element == UtilityService<String> {
    
    static let preview: Self = (0..<10).map { _ in
        
            .init(
                id: UUID().uuidString,
                name: UUID().uuidString,
                icon: UUID().uuidString
            )
    }
}

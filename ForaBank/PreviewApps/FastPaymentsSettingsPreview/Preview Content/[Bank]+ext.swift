//
//  [Bank]+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

extension Array where Element == Bank {
    
    static let preview: Self = ["a", "b", "c", "d", "e", "f"].map {
        
        .init(id: .init($0), name: $0.uppercased())
    }
}

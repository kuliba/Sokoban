//
//  ConsentListState.Expanded.SelectableBank+ext.swift
//  
//
//  Created by Igor Malyarov on 13.01.2024.
//

public extension Array where Element == ConsentList.SelectableBank {
    
    static let empty: Self = []
    
    static let preview: Self = .init(banks: .preview, consent: .preview)
    
    static let many: Self = .init(banks: .many, consent: [])
    
    static func consented(
        _ consent: Consent = .preview
    ) -> Self {
        
        .init(banks: .preview, consent: consent)
    }
}

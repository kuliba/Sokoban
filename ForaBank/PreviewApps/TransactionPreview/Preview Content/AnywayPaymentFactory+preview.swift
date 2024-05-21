//
//  AnywayPaymentFactory+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

extension AnywayPaymentFactory {
    
    static var preview: Self {
        
        return .init(
            makeElementView: { 
                
                return .init(state: $0, event: { print($0) }, factory: .preview)
            },
            makeFooterView: { .init() }
        )
    }
}

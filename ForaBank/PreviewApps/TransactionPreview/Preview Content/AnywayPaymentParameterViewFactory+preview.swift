//
//  AnywayPaymentParameterViewFactory+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

extension AnywayPaymentParameterViewFactory {
    
    static var preview: Self {
        
        return .init(
            makeSelectorView: { selector, observe in
            
                fatalError()
            // .init(viewModel: .preview(), factory: .preview)
        })
    }
}

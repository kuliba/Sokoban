//
//  AnywayPaymentParameterViewFactory+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

extension AnywayPaymentParameterViewFactory {
    
    static var preview: Self {
        
        return .init(
            makeSelectorView: { _,_ in fatalError() },
            makeTextInputView: { _,_ in fatalError() }
        )
    }
}

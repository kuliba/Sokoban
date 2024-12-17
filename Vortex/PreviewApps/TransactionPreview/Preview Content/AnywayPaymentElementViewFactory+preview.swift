//
//  AnywayPaymentElementViewFactory+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import SwiftUI

extension AnywayPaymentElementViewFactory 
where IconView == Text {
    
    static var preview: Self {
        
        return .init(
            makeIconView: { Text(String(describing: $0)) },
            makeProductSelectView: { _,_ in
                
                let viewModel = ProductSelectViewModel(
                    initialState: .init(selected: nil),
                    reduce: { state, _  in (state, nil) },
                    handleEffect: { _,_ in }
                )
                let observing = ObservingProductSelectViewModel(
                    observable: viewModel,
                    observe: { _ in }
                )
                
                return .init(viewModel: observing, config: .iFora)
            }, 
            elementFactory: .preview
        )
    }
}

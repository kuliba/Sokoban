//
//  AnywayPaymentWidgetViewFactory+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

extension AnywayPaymentWidgetViewFactory {
    
    static let preview: Self = .init(
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
        }
    )
}

//
//  ObservingProductSelectViewModel+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import PaymentComponents

extension ObservingProductSelectViewModel {
    
    static func preview() -> Self {
        
        return .compose(
            initialState: .init(selected: nil),
            getProducts: { [] },
            observe: { _ in }
        )
    }

    private static func compose(
        initialState: ProductSelect,
        getProducts: @escaping () -> [ProductSelect.Product],
        observe: @escaping (ProductSelect) -> Void
    ) -> Self {
        
        let reducer = ProductSelectReducer(getProducts: getProducts)

        let observable = ProductSelectViewModel(
            initialState: initialState,
            reduce: { (reducer.reduce($0, $1), nil) },
            handleEffect: { _,_ in }
        )
        return .init(observable: observable, observe: observe)
    }
}

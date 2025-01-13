//
//  ProductPicker.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 17.04.2024.
//

import CombineSchedulers
import RxViewModel
import SwiftUI

typealias ProductPickerViewModel = RxViewModel<ProductSelect, ProductSelectEvent, Never>

struct ProductPicker<ProductView: View>: View {
    
    @StateObject private var viewModel: ProductPickerViewModel
    
    private let config: ProductSelectConfig
    private let productView: (ProductSelect.Product) -> ProductView
    
    init(
        selected: ProductSelect.Product?,
        getProducts: @escaping () -> ProductSelect.Products,
        onSelect: @escaping (ProductSelect.Product) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        config: ProductSelectConfig,
        productView: @escaping (ProductSelect.Product) -> ProductView
    ) {
        self.config = config
        self.productView = productView
        
        let reducer = ProductSelectReducer(getProducts: getProducts)
        let decorated: ProductPickerViewModel.Reduce = { state, event in
            
            if case let .select(product) = event {
                
                onSelect(product)
            }
            
            return (reducer.reduce(state, event), nil)
        }
        self._viewModel = .init(wrappedValue: .init(
            initialState: .init(
                selected: selected,
                products: nil
            ),
            reduce: decorated,
            handleEffect: { _,_ in },
            scheduler: scheduler
        ))
    }
    
    var body: some View {
        
        ProductSelectView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: config,
            productView: productView
        )
    }
}

extension ProductPicker where ProductView == ProductCardView {
    
    init(
        selected: ProductSelect.Product?,
        getProducts: @escaping () -> ProductSelect.Products,
        onSelect: @escaping (ProductSelect.Product) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        config: ProductSelectConfig,
        cardConfig: ProductCardConfig
    ) {
        self.init(
            selected: selected,
            getProducts: getProducts,
            onSelect: onSelect,
            scheduler: scheduler,
            config: config,
            productView: {
                
                .init(
                    productCard: .init(product: $0),
                    config: cardConfig, 
                    isSelected: selected?.id == $0.id
                )
            }
        )
    }
}

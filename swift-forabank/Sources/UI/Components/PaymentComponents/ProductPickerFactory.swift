//
//  ProductPickerFactory.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 17.04.2024.
//

import CombineSchedulers
import SwiftUI

public final class ProductPickerFactory {
    
    private let selected: ProductSelect.Product?
    private let getProducts: GetProducts
    private let config: ProductSelectConfig
    private let cardConfig: ProductCardConfig
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        selected: ProductSelect.Product?,
        getProducts: @escaping GetProducts,
        config: ProductSelectConfig,
        cardConfig: ProductCardConfig,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.selected = selected
        self.getProducts = getProducts
        self.config = config
        self.cardConfig = cardConfig
        self.scheduler = scheduler
    }
}

extension ProductPickerFactory {
    
    public func makeProductPicker<ProductView: View>(
        onSelect: @escaping (ProductSelect.Product) -> Void,
        productView: @escaping (ProductSelect.Product) -> ProductView
    ) -> some View {
        
        ProductPicker(
            selected: selected,
            getProducts: getProducts,
            onSelect: onSelect,
            scheduler: scheduler,
            config: config,
            productView: productView
        )
    }
    
    /// With `PaymentComponents.ProductCardView`.
    public func makeDefaultProductPicker(
        onSelect: @escaping (ProductSelect.Product) -> Void
    ) -> some View {
        
        ProductPicker(
            selected: selected,
            getProducts: getProducts,
            onSelect: onSelect,
            scheduler: scheduler,
            config: config,
            cardConfig: cardConfig
        )
    }
}

extension ProductPickerFactory {
    
    public typealias Product = ProductSelect.Product
    public typealias GetProducts = () -> [Product]
}

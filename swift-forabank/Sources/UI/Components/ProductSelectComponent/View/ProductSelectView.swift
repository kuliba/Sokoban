//
//  ProductSelectView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI
import UIPrimitives

public struct ProductSelectView<ProductView: View>: View {
    
    let state: ProductSelect
    let event: (ProductSelectEvent) -> Void
    let config: ProductSelectConfig
    let productView: (ProductSelect.Product) -> ProductView
    
    public init(
        state: ProductSelect,
        event: @escaping (ProductSelectEvent) -> Void,
        config: ProductSelectConfig,
        productView: @escaping (ProductSelect.Product) -> ProductView
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.productView = productView
    }
    
    public var body: some View {
        
        VStack(spacing: 10) {
            
            switch (state.selected, state.products) {
            case (.none, .none):
                missingSelectedProductView("Данные счёта")
                
            case let (.none, .some(products)):
                missingSelectedProductView("Выберите счёт")
                productsView(products: products)
                
            case let (.some(selected), .none):
                selectedProductView(selected)
                    .padding(.default)
                
            case let (.some(selected), .some(products)):
                selectedProductView(selected)
                    .padding(.default)
                
                productsView(products: products)
            }
        }
        .animation(.easeInOut, value: state)
    }
    
    private func missingSelectedProductView(
        _ title: String
    ) -> some View {
        
        HStack(spacing: 12) {
            
            ZStack(alignment: .topLeading) {
                
                config.missingSelected.backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .frame(height: 22)
                
                config.missingSelected.image
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(config.missingSelected.foregroundColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 5, height: 5)
                    .padding(5)
            }
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                
                "Счёт списания и зачисления".text(withConfig: config.header)
                
                title.text(withConfig: config.missingSelected.title)
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            chevron()
        }
        .contentShape(Rectangle())
        .onTapGesture { event(.toggleProductSelect) }
        .padding(.default)
    }
    
    private func selectedProductView(
        _ product: ProductSelect.Product
    ) -> some View {
        
        HStack(spacing: 12) {
            
            productIcon(product.look.icon)
            productTitle(product, config: config)
        }
        .contentShape(Rectangle())
        .onTapGesture { event(.toggleProductSelect) }
    }
    
    private func productIcon(_ icon: Icon) -> some View {
        
        icon.image(orColor: .clear)
            .frame(width: 32, height: 32)
    }
    
    private func productTitle(
        _ product: ProductSelect.Product,
        config: ProductSelectConfig
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            product.header.text(withConfig: config.header)
            
            HStack(alignment: .center, spacing: 8) {
                
                product.title.text(withConfig: config.title)
                
                Spacer()
                
                product.amountFormatted.text(withConfig: config.amount)
                
                chevron()
            }
            
            product.number.text(withConfig: config.footer)
                .padding(.top, 4)
        }
    }
    
    @ViewBuilder
    private func productsView(
        products: [ProductSelect.Product]
    ) -> some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 10) {
                
                ForEach(products, content: _productView)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    private func _productView(
        product: ProductSelect.Product
    ) -> some View {
        
        productView(product)
            .onTapGesture { event(.select(product)) }
    }
    
    private func chevron() -> some View {
        
        config.chevron.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(config.chevron.color)
            .frame(width: 24, height: 24)
            .rotationEffect(.degrees(state.isExpanded ? 180 : 0))
    }
}

private extension ProductSelect {
    
    var isExpanded: Bool { products != nil }
}

// MARK: - Previews

struct ProductSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            ProductSelectView_Demo(.emptySelectedEmptyProducts())
            ProductSelectView_Demo(.emptySelectedNonEmptyProducts())
            ProductSelectView_Demo(.compact())
            ProductSelectView_Demo(.expanded())
        }
    }
    
    private struct ProductSelectView_Demo: View {
        
        @State private var state: ProductSelect
        
        private let reduce: (ProductSelect, ProductSelectEvent) -> ProductSelect
        
        init(_ state: ProductSelect) {
            
            self._state = .init(initialValue: state)
            
            let reducer = ProductSelectReducer(getProducts: { .allProducts })
            self.reduce = reducer.reduce(_:_:)
        }
        
        var body: some View {
            
            ProductSelectView(
                state: state,
                event: { state = reduce(state, $0) },
                config: .preview
            ) {
                ProductCardView(
                    productCard: .init(product: $0),
                    config: .preview
                )
            }
            .border(.red)
        }
    }
}

private extension ProductSelect {
    
    static func emptySelectedEmptyProducts() -> Self {
        
        .init(selected: nil)
    }
    
    static func emptySelectedNonEmptyProducts() -> Self {
        
        .init(selected: nil, products: .allProducts)
    }
    
    static func compact(
        selected: ProductSelect.Product = .cardPreview
    ) -> Self {
        
        .init(selected: selected)
    }
    
    static func expanded(
        selected: ProductSelect.Product = .cardPreview
    ) -> Self {
        
        .init(selected: selected, products: .allProducts)
    }
}

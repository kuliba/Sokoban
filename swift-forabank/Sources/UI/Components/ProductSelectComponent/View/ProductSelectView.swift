//
//  ProductSelectView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SharedConfigs
import SwiftUI

public struct ProductSelectView<ProductView: View>: View {
    
    let state: ProductSelect
    let event: (ProductSelectEvent) -> Void
    let config: ProductSelectConfig
    let productView: (ProductSelect.Product) -> ProductView
    #warning("move cardSize into config")
    private let cardSize: CGSize
    
    public init(
        state: ProductSelect,
        event: @escaping (ProductSelectEvent) -> Void,
        config: ProductSelectConfig,
        cardSize: CGSize = .init(width: 112, height: 71),
        productView: @escaping (ProductSelect.Product) -> ProductView
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.cardSize = cardSize
        self.productView = productView
    }
    
    public var body: some View {
        
        VStack(spacing: 10) {
            
            switch (state.selected, state.products) {
            case (.none, .none):
                Text("No products avail")
                    .foregroundColor(.red.opacity(0.5))
                
            case let (.none, .some(products)):
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
            .onTapGesture { event(.select(product.id)) }
    }
    
    private func chevron() -> some View {
        
        Image(systemName: "chevron.up")
            .foregroundColor(config.chevronColor)
            .frame(width: 24, height: 24)
            .rotationEffect(.degrees(state.isExpanded ? 0 : 180))
            .onTapGesture { event(.toggleProductSelect) }
    }
}

private extension ProductSelect {
    
    var isExpanded: Bool { products != nil }
}

// MARK: - Previews

struct ProductSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            ProductSelectView_Demo(.emptySelected())
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
    
    static func emptySelected() -> Self {
        
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

//
//  ProductSelectView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

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
            
            selectedProductView(state.selected)
                .padding(.default)
            
            state.products.map(productsView)
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
            
            text(product.header, config: config.header)
            
            HStack(alignment: .center, spacing: 8) {
                
                text(product.title, config: config.title)
                
                Spacer()
                
                text(product.amountFormatted, config: config.amount)
                
                chevron()
            }
            
            text(product.number, config: config.footer)
                .padding(.top, 4)
        }
    }
    
    private func text(
        _ text: String,
        config: TextConfig
    ) -> some View {
        
        Text(text)
            .font(config.textFont)
            .foregroundColor(config.textColor)
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
                config: .default
            ) {
                ProductCardView(
                    productCard: .init(product: $0),
                    config: .default
                )
            }
            .border(.red)
        }
    }
}

private extension ProductSelect {
    
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

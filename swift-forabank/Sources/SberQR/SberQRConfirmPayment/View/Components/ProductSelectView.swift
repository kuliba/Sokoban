//
//  ProductSelectView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct ProductSelectView: View {
    
    typealias Event = SberQRConfirmPaymentEvent.ProductSelectEvent
    
    let state: ProductSelect
    let event: (Event) -> Void
    let config: ProductSelectConfig
    
    private let cardSize = CGSize(width: 112, height: 71)
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            selectedProductView(state.product)
            state.products.map(productsView)
        }
        .animation(.easeInOut, value: state)
    }
    
    private func selectedProductView(
        _ product: ProductSelect.Product
    ) -> some View {
        
        HStack(spacing: 12) {
            
            productIcon(product.icon)
            productTitle(product, config: config)
        }
        .contentShape(Rectangle())
        .onTapGesture { event(.toggleProductSelect) }
    }
    
    private func productIcon(_ icon: Icon) -> some View {
        
        Group {
     
            if let image = icon.image {
                
                image
                    .resizable()
            } else {
                
                Color.clear
            }
        }
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
                
                ForEach(products, content: productCardView)
            }
        }
    }
    
    private func productCardView(
        product: ProductSelect.Product
    ) -> some View {
        
        VStack(spacing: 8) {
            
            HStack {
                
                Color.clear
                    .frame(width: 20, height: 20)
                
                text(product.number, config: config.card.number)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                text(product.title, config: config.card.title)
                
                text(product.amountFormatted, config: config.card.amount)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.caption.bold())
        .padding(.card)
        .frame(cardSize)
        .background(Color.orange.opacity(0.5)) // product.color
        .cornerRadius(8)
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
    
    var isExpanded: Bool {
        
        switch self {
        case .compact:
            return false
            
        case .expanded:
            return true
        }
    }
    
    var product: ProductSelect.Product {
        
        switch self {
        case let .compact(product):
            return product
            
        case let .expanded(product, _):
            return product
        }
    }
    
    var products: [ProductSelect.Product]? {
        
        switch self {
        case .compact:
            return nil
            
        case let .expanded(_, products):
            return products
        }
    }
}

// MARK: - Previews

struct ProductSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            ProductSelectView_Demo(.compact(.cardPreview))
            ProductSelectView_Demo(.expanded(.cardPreview, .allProducts))
        }
        .padding()
    }
    
    private struct ProductSelectView_Demo: View {
        
        @State private var state: ProductSelect
        
        private let reduce: (ProductSelectReducer.State, ProductSelectReducer.Event) -> ProductSelectReducer.State
        
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
            )
            .border(.red)
        }
    }
}

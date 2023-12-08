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
    
    var body: some View {
        
        VStack {
            
            HStack {
                
            Text("ProductSelect")
                .onTapGesture {
                    event(.toggleProductSelect)
                }
                
                Spacer()
                
                chevron()
            }
            
            state.products.map(productsView)
        }
    }
    
    @ViewBuilder
    private func productsView(
        products: [ProductSelect.Product]
    ) -> some View {
        
            ScrollView(.horizontal) {
                
                HStack {
                    
                    ForEach(products, content: productCardView)
                }
            }
    }
    
    private func productCardView(
        product: ProductSelect.Product
    ) -> some View {
        
        Text(product.title)
            .font(.caption.bold())
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.orange.opacity(0.5)) // product.color
            )
    }
    
    private func chevron() -> some View {
        
        Image(systemName: "chevron.up")
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

struct ProductSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            ProductSelectView_Demo(.compact(.cardPreview))
            ProductSelectView_Demo(.expanded(.cardPreview, [.cardPreview, .accountPreview]))
        }
        .padding()
    }
    
    private struct ProductSelectView_Demo: View {
        
        @State private var state: ProductSelect
        
        private let reduce: (ProductSelectReducer.State, ProductSelectReducer.Event) -> ProductSelectReducer.State
        
        init(_ state: ProductSelect) {
         
            self._state = .init(initialValue: state)
            
            let reducer = ProductSelectReducer(getProducts: { [.cardPreview, .accountPreview] })
            self.reduce = reducer.reduce(_:_:)
        }
        
        var body: some View {
            
            ProductSelectView(
                state: state,
                event: { event in
                    
                    self.state = reduce(state, event)
                }
            )
            .border(.red)
        }
    }
}

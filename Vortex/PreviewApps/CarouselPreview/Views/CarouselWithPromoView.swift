//
//  CarouselWithPromoView.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 20.01.2025.
//

import SwiftUI

struct CarouselWithPromoView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 5) {
                
                ForEach(Array.allTypes, content: product(_:))
            }
        }
    }

    @ViewBuilder
    func product(_ type: ProductType) -> some View {
        
        let productsForType = state.products.allItemBy(type)
        
        ForEach(productsForType, content: { product($0, productsForType.isLast(element: $0))} )
    }
    
    @ViewBuilder
    func product(_ product: Item, _ isLast: Bool) -> some View {
        
        Button(action: { event(.product(.tap(product.id))) }) {
            
            Text(product.title)
                .foregroundColor(.white)
                .frame(width: 164, height: 104)
        }
        .background(product.color)
        .cornerRadius(12)
        
        if isLast {
            
            let promoForType = state.promo.allItemBy(product.type)
            
            ForEach(promoForType, content: promo(_:))
            
            let newProductsForType = state.newProducts.allItemBy(product.type)

            ForEach(newProductsForType, content: newProduct(_:))
        }
    }
    
    @ViewBuilder
    func promo(_ promo: Promo) -> some View {
        
        if !promo.isHidden {
            ZStack(alignment: .topTrailing) {
                Text(promo.title)
                    .foregroundColor(.white)
                    .frame(width: 164, height: 104)
                    .background(promo.color)
                    .cornerRadius(12)
                    .onTapGesture {
                        event(.promo(.tap(promo.id)))
                    }
                Button(
                    action: { event(.promo(.hidden(promo.id))) },
                    label: { Image(systemName: "xmark") }
                )
                .background(.white)
                .cornerRadius(12)
                .padding(.all, 5)
            }
        }
    }
    
    @ViewBuilder
    func newProduct(_ type: ProductType) -> some View {
        
        let productsForType = state.newProducts.allItemBy(type)
        
        ForEach(productsForType, content: newProduct(_:) )
    }
    
    func newProduct(_ newProduct: NewProduct) -> some View {
        
        Button(
            action: { event(.newProduct(.tap(newProduct.id))) },
            label: {                 
                Text(newProduct.title)
                    .foregroundColor(.white)
            }
        )
        .frame(width: 164, height: 104)
        .background(newProduct.color)
        .cornerRadius(12)
    }
}

extension CarouselWithPromoView {
    
    typealias State = CarouselState
    typealias Event = CarouselEvent
    typealias ProductType = Product.ProductType
}

#Preview {
    
    CarouselWithPromoView(
        state: .preview,
        event: CarouselWithPromoView.event
    )
}

extension Array where Element: Equatable {
    
    func isLast(element: Element) -> Bool {
        
        element == last
    }
}

extension Array where Element: ProductTypeable {
    
    func allItemBy(_ type: Product.ProductType) -> [Element] {
        
        filter { $0.type == type }
    }
}

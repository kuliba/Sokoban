//
//  CarouselView.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

struct CarouselView<Product, ProductView, NewProductButton, StickerView>: View
where Product: CarouselProduct & Equatable & Identifiable,
      ProductView: View,
      NewProductButton: View,
      StickerView: View {

    let state: State
    let event: (Event) -> Void
    
    let productView: (Product) -> ProductView
    let stickerView: () -> StickerView?
    let newProductButton: () -> NewProductButton?
    
    let config: CarouselComponentConfig
        
    var body: some View {
                
        if isEmptyProducts {
            
            EmptyView()

        } else {
            
            VStack() {
                
                SelectorView(
                    selector: state.selector,
                    action: { event(.select($0, delay: 0.2)) }, 
                    config: config.selector
                )
                
                ProductGroupsView<Product, ProductView, NewProductButton, StickerView>(
                    state: state,
                    groups: state.productGroups,
                    event: event,
                    productView: productView, 
                    stickerView: stickerView, 
                    newProductButton: newProductButton,
                    config: config.carousel
                )
            }
        }
    }
    
    private var isEmptyProducts: Bool {
        
        state.productGroups.isEmpty
    }
}

extension CarouselView {
    
    typealias State = CarouselState<Product>
    typealias Event = CarouselEvent<Product>
}

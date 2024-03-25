//
//  CarouselView.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

struct CarouselView<ProductView: View, NewProductButton: View, StickerView: View>: View {

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
                    state: state.selector,
                    action: { event(.select($0, delay: 0.2)) }, 
                    config: config.selector
                )
                
                ProductGroupsView<ProductView, NewProductButton, StickerView>(
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
    
    typealias State = CarouselState
    typealias Event = CarouselEvent
}

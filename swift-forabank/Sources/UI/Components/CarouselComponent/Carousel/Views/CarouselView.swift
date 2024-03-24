//
//  CarouselView.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

public struct CarouselView<ProductView: View, NewProductButton: View, StickerView: View>: View {

    let state: CarouselState
    let event: (CarouselEvent) -> Void
    
    let productView: (CarouselProduct) -> ProductView
    let stickerView: () -> StickerView?
    let newProductButton: () -> NewProductButton?
    
    let config: CarouselComponentConfig
    
    public init(
        state: CarouselState,
        event: @escaping (CarouselEvent) -> Void,
        productView: @escaping (CarouselProduct) -> ProductView,
        stickerView: @escaping () -> StickerView?,
        newProductButton: @escaping () -> NewProductButton?,
        config: CarouselComponentConfig
    ) {
        self.state = state
        self.event = event
        self.productView = productView
        self.stickerView = stickerView
        self.newProductButton = newProductButton
        self.config = config
    }
    
    public var body: some View {
                
        if isEmptyProducts {
            
            EmptyView()

        } else {
            
            VStack() {
                
                SelectorView(
                    state: state.selector,
                    event: { event(.select($0, delay: 0.2)) }, 
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

//
//  CarouselView.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

public struct CarouselView<ProductView: View, ButtonNewProduct: View, StickerView: View>: View {

    let state: CarouselState
    let event: (CarouselEvent) -> Void
    
    let productView: (Product) -> ProductView
    let stickerView: (Product) -> StickerView?
    let buttonNewProduct: () -> ButtonNewProduct?
    
    let carouselComponentConfiguration: CarouselComponentConfiguration
    
    public init(
        state: CarouselState,
        event: @escaping (CarouselEvent) -> Void,
        productView: @escaping (Product) -> ProductView,
        stickerView: @escaping (Product) -> StickerView?,
        buttonNewProduct: @escaping () -> ButtonNewProduct?,
        carouselComponentConfiguration: CarouselComponentConfiguration
    ) {
        self.state = state
        self.event = event
        self.productView = productView
        self.stickerView = stickerView
        self.buttonNewProduct = buttonNewProduct
        self.carouselComponentConfiguration = carouselComponentConfiguration
    }
    
    public var body: some View {
                
        if isEmptyProducts {
            
            EmptyView()

        } else {
            
            VStack() {
                
                SelectorView(
                    state: state.selector,
                    event: { event(.select($0, delay: 0.2)) }, 
                    configuration: carouselComponentConfiguration.selectorConfiguration
                )
                
                ProductGroupsView<ProductView, ButtonNewProduct, StickerView>(
                    state: state,
                    groups: state.productGroups,
                    event: event,
                    productView: productView, 
                    stickerView: stickerView, 
                    buttonNewProduct: buttonNewProduct,
                    carouselConfiguration: carouselComponentConfiguration.carouselConfiguration
                )
            }
        }
    }
    
    private var isEmptyProducts: Bool {
        
        state.productGroups.isEmpty
    }
}

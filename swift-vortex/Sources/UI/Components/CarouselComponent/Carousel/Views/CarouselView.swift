//
//  CarouselView.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

public struct CarouselView<Product, ProductView, NewProductButton, StickerView>: View
where Product: CarouselProduct & Equatable & Identifiable,
      ProductView: View,
      NewProductButton: View,
      StickerView: View {

    private let state: State
    private let event: (Event) -> Void
    
    private let productView: (Product) -> ProductView
    private let stickerView: () -> StickerView?
    private let newProductButton: () -> NewProductButton?
    
    private let config: CarouselComponentConfig
        
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        productView: @escaping (Product) -> ProductView,
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

public extension CarouselView {
    
    typealias State = CarouselState<Product>
    typealias Event = CarouselEvent<Product>
}

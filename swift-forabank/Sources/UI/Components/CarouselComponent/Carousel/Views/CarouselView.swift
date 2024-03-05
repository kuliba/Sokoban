//
//  CarouselView.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

public struct CarouselView<ProductView: View>: View {

    let state: CarouselState
    let event: (CarouselEvent) -> Void
    let productView: (Product) -> ProductView
    
    public init(
        state: CarouselState,
        event: @escaping (CarouselEvent) -> Void,
        productView: @escaping (Product) -> ProductView
    ) {
        self.state = state
        self.event = event
        self.productView = productView
    }
    
    public var body: some View {
        
        // TODO: - Причесать и уточнить у дизайнера, что показываем когда нет продуктов
        
        if isEmptyProducts {
            
            Text("No products")
            
        } else {
            
            VStack() {
                
                SelectorView(
                    state: state.selector,
                    event: { event(.select($0, delay: 0.2)) }
                )
                
                ProductGroupsView(
                    state: state,
                    groups: state.productGroups,
                    event: event,
                    productView: productView
                )
            }
        }
    }
    
    private var isEmptyProducts: Bool {
        
        state.productGroups.isEmpty
    }
}

//
//  CarouselReducer.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel
import Foundation

public final class CarouselReducer<Product: CarouselProduct & Equatable> {
        
    public init() { }
}

extension CarouselReducer {
    
    public func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .toggle(id: groupID, screenwidth: screenWidth, xOffset: xOffset):
            state[groupID]?.state.toggle()
            
            if state[groupID]?.state == .collapsed {
                
                state.spoilerUnitPoints = GeometryHelpers.getSpoilerUnitPoint(
                    screenWidth: screenWidth,
                    xOffset: xOffset
                )
            }
            
        case let .scrolledTo(groupID):
            state.selectedProductType = groupID
            state.selector.selected = groupID

        case let .select(productType, delay):
            effect = .scrollTo(productType, delay)
        
        case let .didScrollTo(xOffset):
            if let groupID = state.productType(with: xOffset) {
                state.selector.selected = groupID
            }
            
        case let .update(products):
            state = .init(products: products, needShowSticker: state.needShowSticker)
            
        case .closeSticker:
            state.needShowSticker = false
        }
        
        return (state, effect)
    }
}

public extension CarouselReducer {
    
    typealias State = CarouselState<Product>
    typealias Event = CarouselEvent<Product>
    typealias Effect = CarouselEffect
}

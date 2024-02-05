//
//  ComposedCarouselView.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import SwiftUI

public struct ComposedCarouselView: View {
    
    let state: ComposedCarouselState
    let event: (ComposedCarouselEvent) -> Void
    
    public var body: some View {
        
        switch state.selectorCarouselState {
        case .initial(let model):
            
            SelectorWrapperView(viewModel: SelectorFactory().makeViewModel())
        }
        
        switch state.carouselCarouselState {
        case .initial(let model):
            
            CarouselWrapperView(viewModel: CarouselFactory().makeViewModel())
        }
    }
}

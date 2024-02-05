//
//  ComposedCarouselWrapperView.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import SwiftUI

public struct ComposedCarouselWrapperView: View {
    
    @StateObject var viewModel: ComposedCarouselViewModel
    
    public init(
        viewModel: ComposedCarouselViewModel
    ) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    public var body: some View {
        
        ComposedCarouselView(
            state: viewModel.state,
            event: viewModel.event
        )
    }
}

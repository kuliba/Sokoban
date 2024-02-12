//
//  CarouselWrapperView.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

public struct CarouselWrapperView: View {
    
    @StateObject var viewModel: CarouselViewModel
    
    public init(
        viewModel: CarouselViewModel
    ) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    public var body: some View {
        
        CarouselView(
            state: viewModel.state,
            event: viewModel.event
        )
    }
}


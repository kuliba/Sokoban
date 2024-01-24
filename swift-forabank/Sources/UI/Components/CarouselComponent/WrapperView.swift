//
//  WrapperView.swift
//  
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

struct WrapperView: View {
    
    @StateObject var viewModel: CarouselComponentViewModel
    
    init(viewModel: CarouselComponentViewModel) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        CarouselView(
            state: viewModel.state,
            event: viewModel.event
        )
    }
}


//
//  CarouselWrapperView.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI

public struct CarouselWrapperView<ProductView: View>: View {
    
    @ObservedObject var viewModel: CarouselViewModel
    
    let productView: (Product) -> ProductView
    
    public init(
        viewModel: CarouselViewModel,
        productView: @escaping (Product) -> ProductView
    ) {
        self.viewModel = viewModel
        self.productView = productView
    }
    
    public var body: some View {
        
        // TODO: - Причесать и уточнить у дизайнера, что показываем когда нет продуктов
        
        CarouselView(state: viewModel.state, event: viewModel.event(_:), productView: productView)
    }
}

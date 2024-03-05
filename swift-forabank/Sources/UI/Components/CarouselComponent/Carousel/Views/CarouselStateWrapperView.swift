//
//  CarouselStateWrapperView.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI

public struct CarouselStateWrapperView<ProductView: View>: View {
    
    @StateObject private var viewModel: CarouselViewModel
    
    private let productView: (Product) -> ProductView
    
    public init(
        products: [Product],
        productView: @escaping (Product) -> ProductView
    ) {
        let viewModel = CarouselViewModel(initialState: .init(products: products))
        self._viewModel = .init(wrappedValue: viewModel)
        self.productView = productView
    }
    
    public var body: some View {
        
        // TODO: - Причесать и уточнить у дизайнера, что показываем когда нет продуктов
        
        CarouselView(state: viewModel.state, event: viewModel.event(_:), productView: productView)
    }
}

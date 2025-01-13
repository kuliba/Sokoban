//
//  CarouselStateWrapperView.swift
//
//
//  Created by Andryusina Nataly on 28.03.2024.
//

import SwiftUI

public struct CarouselStateWrapperView<Product, ProductView, NewProductButton, StickerView>: View
where Product: CarouselProduct & Equatable & Identifiable,
      ProductView: View,
      NewProductButton: View,
      StickerView: View {
    
    public typealias ViewModel = CarouselViewModel<Product>
    
    @StateObject private var viewModel: ViewModel
    
    private let productView: (Product) -> ProductView
    private let stickerView: () -> StickerView?
    private let newProductButton: () -> NewProductButton?
    
    private let config: CarouselComponentConfig
    
    public init(
        viewModel: ViewModel,
        productView: @escaping (Product) -> ProductView,
        stickerView: @escaping () -> StickerView?,
        newProductButton: @escaping () -> NewProductButton?,
        config: CarouselComponentConfig
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.productView = productView
        self.stickerView = stickerView
        self.newProductButton = newProductButton
        self.config = config
    }
    public var body: some View {
        
        CarouselWrapperView(
            viewModel: viewModel,
            productView: productView,
            stickerView: stickerView,
            newProductButton: newProductButton,
            config: config
        )
    }
}

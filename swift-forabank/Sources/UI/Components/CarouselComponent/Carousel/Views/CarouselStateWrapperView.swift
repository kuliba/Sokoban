//
//  CarouselStateWrapperView.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI

public struct CarouselStateWrapperView<ProductView: View, NewProductButton: View, StickerView: View>: View {
    
    @StateObject private var viewModel: CarouselViewModel
    
    private let productView: (Product) -> ProductView
    private let stickerView: (Product) -> StickerView?
    private let newProductButton: () -> NewProductButton?
    
    private let config: CarouselComponentConfig
    
    public init(
        products: [Product],
        productView: @escaping (Product) -> ProductView,
        stickerView: @escaping (Product) -> StickerView?,
        newProductButton: @escaping () -> NewProductButton?,
        config: CarouselComponentConfig
    ) {
        let viewModel = CarouselViewModel(initialState: .init(products: products))
        self._viewModel = .init(wrappedValue: viewModel)
        self.productView = productView
        self.stickerView = stickerView
        self.newProductButton = newProductButton
        self.config = config
    }
    
    public var body: some View {
                
        CarouselView<ProductView, NewProductButton, StickerView>(
            state: viewModel.state,
            event: viewModel.event(_:),
            productView: productView, 
            stickerView: stickerView, 
            newProductButton: newProductButton,
            config: config
        )
    }
}

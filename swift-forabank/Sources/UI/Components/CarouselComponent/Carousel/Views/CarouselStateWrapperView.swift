//
//  CarouselStateWrapperView.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI

public struct CarouselStateWrapperView<ProductView: View, ButtonNewProduct: View, StickerView: View>: View {
    
    @StateObject private var viewModel: CarouselViewModel
    
    private let productView: (Product) -> ProductView
    private let stickerView: (Product) -> StickerView?
    private let buttonNewProduct: () -> ButtonNewProduct?
    
    private let carouselComponentConfiguration: CarouselComponentConfiguration
    
    public init(
        products: [Product],
        productView: @escaping (Product) -> ProductView,
        stickerView: @escaping (Product) -> StickerView?,
        buttonNewProduct: @escaping () -> ButtonNewProduct?,
        carouselComponentConfiguration: CarouselComponentConfiguration
    ) {
        let viewModel = CarouselViewModel(initialState: .init(products: products))
        self._viewModel = .init(wrappedValue: viewModel)
        self.productView = productView
        self.stickerView = stickerView
        self.buttonNewProduct = buttonNewProduct
        self.carouselComponentConfiguration = carouselComponentConfiguration
    }
    
    public var body: some View {
                
        CarouselView<ProductView, ButtonNewProduct, StickerView>(
            state: viewModel.state,
            event: viewModel.event(_:),
            productView: productView, 
            stickerView: stickerView, buttonNewProduct: buttonNewProduct,
            carouselComponentConfiguration: carouselComponentConfiguration
        )
    }
}

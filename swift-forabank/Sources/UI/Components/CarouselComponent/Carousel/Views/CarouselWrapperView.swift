//
//  CarouselWrapperView.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI

public struct CarouselWrapperView<ProductView: View, ButtonNewProduct: View, StickerView: View>: View {
    
    @ObservedObject var viewModel: CarouselViewModel
    
    private let productView: (Product) -> ProductView
    private let stickerView: (Product) -> StickerView?
    private let buttonNewProduct: () -> ButtonNewProduct?
    
    private let carouselComponentConfiguration: CarouselComponentConfiguration
    
    public init(
        viewModel: CarouselViewModel,
        productView: @escaping (Product) -> ProductView,
        stickerView: @escaping (Product) -> StickerView?,
        buttonNewProduct: @escaping () -> ButtonNewProduct?,
        carouselComponentConfiguration: CarouselComponentConfiguration
    ) {
        self.viewModel = viewModel
        self.productView = productView
        self.stickerView = stickerView
        self.buttonNewProduct = buttonNewProduct
        self.carouselComponentConfiguration = carouselComponentConfiguration
    }
    
    public var body: some View {
                
        CarouselView(
            state: viewModel.state,
            event: viewModel.event(_:),
            productView: productView, 
            stickerView: stickerView, 
            buttonNewProduct: buttonNewProduct,
            carouselComponentConfiguration: carouselComponentConfiguration
        )
    }
}

//
//  CarouselWrapperView.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI

public struct CarouselWrapperView<ProductView: View, NewProductButton: View, StickerView: View>: View {
    
    @ObservedObject var viewModel: CarouselViewModel
    
    private let productView: (Product) -> ProductView
    private let stickerView: () -> StickerView?
    private let newProductButton: () -> NewProductButton?
    
    private let config: CarouselComponentConfig
    
    public init(
        viewModel: CarouselViewModel,
        productView: @escaping (Product) -> ProductView,
        stickerView: @escaping () -> StickerView?,
        newProductButton: @escaping () -> NewProductButton?,
        config: CarouselComponentConfig
    ) {
        self.viewModel = viewModel
        self.productView = productView
        self.stickerView = stickerView
        self.newProductButton = newProductButton
        self.config = config
    }
    
    public var body: some View {
                
        CarouselView(
            state: viewModel.state,
            event: viewModel.event(_:),
            productView: productView, 
            stickerView: stickerView, 
            newProductButton: newProductButton,
            config: config
        )
    }
}

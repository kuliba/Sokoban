//
//  ContentView.swift
//  CarouselPreview
//
//  Created by Igor Malyarov on 15.02.2024.
//

import RxViewModel
import SwiftUI
import CarouselComponent
import CardUI

struct ContentView: View {
    
    var body: some View {
        
        CarouselMainView(
            viewModel: .init(
                initialState: .init(
                    products: .allProducts,
                    sticker: .sticker)
            ),
            products: .preview
        )
        .padding()
    }
}

struct CarouselMainView: View {
    
    @ObservedObject var viewModel: CarouselViewModel
    let products: [ProductData]
    
    init(
        viewModel: CarouselViewModel,
        products: [ProductData]
    ) {
        self.viewModel = viewModel
        self.products = products
    }
    
    var body: some View {
        
        CarouselWrapperView(
            viewModel: viewModel,
            productView: productView(_:),
            stickerView:
                { _ in
                    StickerView(
                        viewModel: .init(
                            title: "Cтикер",
                            subTitle: "Тест",
                            backgroundImage: Image(systemName: "creditcard.fill"),
                            onTap: { },
                            onHide: { }
                        )
                    )
                },
            newProductButton: { NewProductButtonWrapperView(viewModel: .sample, config: .preview, action: { }) },
            config: .preview
        )
    }
    
    
    private func productView(_ product: Product) -> some View {
        
        VStack {
            
            if let productData = products.first(where: { $0.id == product.id.rawValue }) {
                
                ProductFrontView(
                    name: productData.productName,
                    headerDetails: headerDetails(product, productData),
                    footerDetails: .init(balance: productData.balance),
                    modifierConfig: .init(
                        isChecked: false,
                        isUpdating: false,
                        opacity: 1,
                        isShowingCardBack: false,
                        cardWiggle: false,
                        action: { print("Card tap") }),
                    activationView: { EmptyView() },
                    config: {
                        switch product.type {
                        case .card:
                                .preview
                        case .account:
                                .previewAccount
                        case .deposit:
                                .previewDeposit
                        case .loan:
                                .previewLoan
                        }
                    }())
            } else { Text("Empty View") }
        }
    }
    
    private func headerDetails(_ product: Product, _ productData: ProductData) -> HeaderDetails {
        
        switch product.cardType {
        case .regular, .main:
            return .init(number: productData.number, icon: Image(systemName: "circle.grid.cross.fill"))
            
        case .additionalSelf, .additionalSelfAccOwn, .additionalOther:
            return .init(number: productData.number, icon: Image(systemName: "circle.grid.cross.right.filled"))
            
        case .sticker, .none:
            return .init(number: productData.number)
        }
    }
}

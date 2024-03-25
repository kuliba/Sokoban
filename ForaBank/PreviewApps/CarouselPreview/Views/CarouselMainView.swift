//
//  CarouselMainView.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 24.03.2024.
//

import RxViewModel
import SwiftUI
import CarouselComponent
import CardUI

typealias CarouselProduct = CarouselComponent.Product

struct CarouselMainView: View {
    
    @ObservedObject var viewModel: CarouselViewModel
    let products: [Product]
    
    init(
        products: [Product],
        needShowSticker: Bool
    ) {
        self.viewModel = .init(
            initialState: .init(
                products: products.map {
                    .init(
                        id: .init($0.id),
                        type: $0.productType.type,
                        isAdditional: $0.cardType?.isAdditional,
                        isMainOrRegular: $0.cardType?.isMainOrRegular
                    )
                },
                needShowSticker: needShowSticker))
        self.products = products
    }
    
    var body: some View {
        
        CarouselWrapperView(
            viewModel: viewModel,
            productView: productView(_:),
            stickerView:
                {
                    StickerView(
                        viewModel: .init(
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
    
    
    private func productView(_ carouselProduct: CarouselProduct) -> some View {
        
        VStack {
            
            if let product = products.first(where: { $0.id == carouselProduct.id.rawValue }) {
                
                ProductFrontView(
                    name: product.productName,
                    headerDetails: headerDetails(product),
                    footerDetails: .init(balance: product.balance, paymentSystem: Image(systemName: "sparkles")),
                    modifierConfig: .init(
                        isChecked: false,
                        isUpdating: false,
                        opacity: 1,
                        isShowingCardBack: false,
                        cardWiggle: false,
                        action: { print("Card tap") }),
                    activationView: { EmptyView() },
                    config: {
                        switch carouselProduct.type {
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
    
    private func headerDetails(_ product: Product) -> HeaderDetails {
        
        switch product.cardType {
        case .regular, .main:
            return .init(number: product.number, icon: Image(systemName: "circle.grid.cross.fill"))
            
        case .additionalSelf, .additionalSelfAccOwn, .additionalOther:
            return .init(number: product.number, icon: Image(systemName: "circle.grid.cross.right.filled"))
            
        case .none:
            return .init(number: product.number)
        }
    }
}

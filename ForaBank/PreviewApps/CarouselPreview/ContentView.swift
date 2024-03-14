//
//  ContentView.swift
//  CarouselPreview
//
//  Created by Igor Malyarov on 15.02.2024.
//

import RxViewModel
import SwiftUI
import CarouselComponent

struct ContentView: View {
        
    var body: some View {
        
        CarouselMainView(
            viewModel: .init(initialState: .init(products: .allProducts, sticker: .sticker))) { product in
                
                switch product.id.type {
                case .account:
                    return ProductView(viewModel: .account)
                    
                case .card:
                    if product.id.cardType?.isAdditional == true {
                        return ProductView(viewModel: .additionalCard)
                    }
                    else {
                        if product.id.cardType == .main {
                            return ProductView(viewModel: .additionalMain)
                        }
                        else {
                            return ProductView(viewModel: .additionalRegular)
                        }
                    }
                    
                case .deposit:
                    return ProductView(viewModel: .depositProfile)
                    
                case .loan:
                    return ProductView(viewModel: .blocked)
                    
                }
            }
    }
}

struct CarouselMainView: View {
    
    @ObservedObject var viewModel: CarouselViewModel
    
    private let productView: (Product) -> ProductView
    
    init(
        viewModel: CarouselViewModel,
        productView: @escaping (Product) -> ProductView
    ) {
        self.viewModel = viewModel
        self.productView = productView
    }
    
    var body: some View {
        
        CarouselWrapperView(
            viewModel: viewModel,
            productView: productView,
            stickerView:
                { _ in
                    StickerView(
                        viewModel: .init(
                            title: "Cтикер",
                            subTitle: "Тест",
                            backgroundImage: Image("StickerPreview"),
                            onTap: { },
                            onHide: { }
                        )
                    )
                },
            newProductButton: { NewProductButtonWrapperView(viewModel: .sample, config: .sample, action: { }) },
            config: carouselComponentConfig
        )
    }
    
    var carouselComponentConfig: CarouselComponentConfig {
        
        .init(carousel: .init(
            item: .init(
                spacing: 13,
                horizontalPadding: 20
            ),
            group: .init(
                spacing: 8,
                buttonFont: Font.custom("Inter-Medium", size: 14.0),
                shadowForeground: Color(hex: "#1C1C1C"),
                buttonForegroundPrimary: Color.bordersDivider,
                buttonForegroundSecondary: Color.textSecondary,
                buttonIconForeground: Color.bordersDivider
            ),
            spoilerImage: Image("shevronDown"),
            separatorForeground: Color.bordersDivider,
            productDimensions: .regular),
              selector: .init(
                optionConfig: .init(
                    frameHeight: 24,
                    textFont: Font.custom("Inter", size: 12.0),
                    textForeground: Color.textPlaceholder,
                    textForegroundSelected: Color.textSecondary,
                    shapeForeground: .white,
                    shapeForegroundSelected: Color.grayLightest
                ),
                itemSpacing: 8
              )
        )
    }
}

//struct TopView: View {
//
//    @StateObject var viewModel: CarouselViewModel
//    @State private var selectedProduct: Product?
//    @State private var isShowing = true
//
//    var body: some View {
//
//        VStack {
//
//            Toggle(isOn: $isShowing) {
//
//                Text("Show/hide")
//            }
//
//            Button("Update products") {
//
//                viewModel.event(.update(.cards))
//            }
//
//            Button("Add more products") {
//
//                viewModel.event(.update(.cards + .moreProducts))
//            }
//            .padding()
//
//            if isShowing {
//
//                CarouselWrapperView(viewModel: viewModel) { product in
//
//                    ProductView(product: product)
//                        .onTapGesture { selectedProduct = product }
//                }
//            }
//        }
//        .sheet(item: $selectedProduct) {
//
//            $0.color
//                .frame(width: 200, height: 200)
//        }
//    }
//}

//struct BottomView: View {
//
//    @State private var product: Product = .card
//    @State private var isShowing = false
//
//    var body: some View {
//
//        VStack {
//
//            HStack {
//
//                product.color
//                    .frame(width: 100, height: 32)
//                    .overlay { Text("\(product.id.value.rawValue)") }
//
//                Spacer()
//
//                Button("Show products") {
//
//                    isShowing.toggle()
//                }
//            }
//            .padding()
//
//            if isShowing {
//
//                CarouselStateWrapperView(products: .cards) { product in
//
//                    ProductView(product: product)
//                        .onTapGesture {
//
//                            self.product = product
//                            isShowing = false
//                        }
//                }
//            }
//        }
//    }
//}
//
//struct ProductView: View {
//
//    let product: Product
//
//    var body: some View {
//
//        product.color
//            .cornerRadius(10)
//            .frame(width: 121, height: 70)
//            .overlay { Text("\(product.id.value.rawValue)") }
//    }
//}

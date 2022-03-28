//
//  AuthProductsViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 11.02.2022.
//

import Foundation
import SwiftUI
import Combine

class AuthProductsViewModel: ObservableObject {

    let navigationBar: NavigationBarViewModel
    @Published var productCards: [ProductCard]
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    init(_ model: Model = .emptyMock, productCards: [ProductCard], dismissAction: @escaping () -> Void = {}) {

        self.navigationBar = NavigationBarViewModel(title: "Выберите продукт", action: dismissAction)
        self.productCards = productCards
        self.model = model
    }
    
    init(_ model: Model, products: [CatalogProductData], dismissAction: @escaping () -> Void = {}) {

        self.navigationBar = NavigationBarViewModel(title: "Выберите продукт", action: dismissAction)
    
        self.productCards = products.enumerated().map({ product in
            
            ProductCard(with: product.element, style: .init(number: product.offset))
        })
        self.model = model
        
        bind()
        requestImages(for: products)
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.Auth.ProductImage.Response:
                    switch payload.result {
                    case .success(let data):
      
                        guard let image = Image(data: data) else {
                            //TODO: log
                            print("AuthProductsViewModel: unable create product image from data for endpoint: \(payload.endpoint)")
                            return
                        }
                        
                        guard let productCard = productCards.first(where: { productCard in
                            
                            guard case .endpoint(let endpoint) = productCard.image else {
                                return false
                            }
                            
                            return endpoint == payload.endpoint
                            
                        }) else {
                            
                            return
                        }
                        
                        withAnimation {
                            
                            productCard.image = .image(image)
                        }
                        
                    case .failure(let error):
                        //TODO: log
                        print("AuthProductsViewModel: product image download failed for endpoint: \(payload.endpoint) with error: \(error.localizedDescription)")
                    }
    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func requestImages(for products: [CatalogProductData]) {
        
        for product in products {
        
            model.action.send(ModelAction.Auth.ProductImage.Request(endpoint: product.imageEndpoint))
        }
    }
}

extension AuthProductsViewModel {

    struct NavigationBarViewModel {
        
        let title: String
        let backButton: BackButtonViewModel

        struct BackButtonViewModel {
            let icon: Image = .ic24ChevronLeft
            let action: () -> Void
        }
        
        init(title: String, action: @escaping () -> Void) {

            self.title = title
            self.backButton = BackButtonViewModel(action: action)
        }
    }
    
    class ProductCard: Identifiable, ObservableObject {

        let id = UUID()
        let style: Style
        let title: String
        let subtitle: [String]
        @Published var image: ImageData
        let infoButton: InfoButton
        let orderButton: OrderButton
        
        internal init(style: Style, title: String, subtitle: [String], image: ImageData, infoButton: InfoButton, orderButton: OrderButton) {
            
            self.style = style
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.infoButton = infoButton
            self.orderButton = orderButton
        }
        
        init(with product: CatalogProductData, style: Style) {
            
            self.style = style
            self.title = product.name
            self.subtitle = product.description
            self.image = .endpoint(product.imageEndpoint)
            self.infoButton = InfoButton(url: product.infoURL)
            self.orderButton = OrderButton(url: product.orderURL)
        }
        
        enum ImageData {
            
            case endpoint(String)
            case image(Image)
        }

        struct InfoButton {

            let title: String = "Подробные условия"
            let icon: Image = .ic24Info
            let url: URL
        }

        struct OrderButton {

            let title: String = "Заказать"
            let url: URL
        }
        
        enum Style {

            case light
            case dark
            
            init(number: Int) {
                
                if number % 2 == 0 {
                    
                    self = .light
                    
                } else {
                    
                    self = .dark
                }
            }
            
            var backgroundColor: Color {

                switch self {
                case .light:
                    return .mainColorsGrayLightest
                case .dark:
                    return .mainColorsBlack
                }
            }
            
            var textColor: Color {

                switch self {
                case .light:
                    return .textSecondary
                case .dark:
                    return .textWhite
                }
            }
        }
    }
}

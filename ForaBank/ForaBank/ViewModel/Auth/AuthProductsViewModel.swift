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

    init(productCards: [ProductCard], dismissAction: @escaping () -> Void = {}) {

        self.navigationBar = NavigationBarViewModel(title: "Выберите продукт", action: dismissAction)
        self.productCards = productCards
    }
    
    init(products: [CatalogProductData], dismissAction: @escaping () -> Void = {}) {

        self.navigationBar = NavigationBarViewModel(title: "Выберите продукт", action: dismissAction)
    
        self.productCards = products.enumerated().map({ product in
            
            ProductCard(with: product.element, style: .init(number: product.offset))
        })
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
    
    struct ProductCard: Identifiable {

        let id = UUID()
        let style: Style
        let title: String
        let subtitle: [String]
        let image: Image
        let infoButton: InfoButton
        let orderButton: OrderButton
        
        internal init(style: Style, title: String, subtitle: [String], image: Image, infoButton: InfoButton, orderButton: OrderButton) {
            
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
            self.subtitle = product.deescription
            //TODO: real implementation here
            self.image = Image("icCardMir")
            self.infoButton = InfoButton(url: product.infoURL)
            self.orderButton = OrderButton(url: product.orderURL)
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

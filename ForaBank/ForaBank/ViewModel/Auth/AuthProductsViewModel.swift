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

    let action: PassthroughSubject<Action, Never> = .init()

    let navigationBar: NavigationBarViewModel
    @Published var productCards: [ProductCard]

    init(productCards: [ProductCard], dismissAction: @escaping () -> Void = {}) {

        self.navigationBar = NavigationBarViewModel(title: "Выберите продукт", action: dismissAction)
        self.productCards = productCards
    }
    
    //TODO: init with real products data
    init(products: [String], dismissAction: @escaping () -> Void = {}) {

        self.navigationBar = NavigationBarViewModel(title: "Выберите продукт", action: dismissAction)
        self.productCards = []
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

        let id: Int
        let style: Style
        let title: LocalizedStringKey
        let subtitle: String
        let image: Image
        let infoButton: InfoButton
        let orderButton: OrderButton

        struct InfoButton {

            let title: String = "Подробные условия"
            let icon: Image = .ic24Info
            let action: () -> Void
        }

        struct OrderButton {

            let title: String = "Заказать"
            let action: () -> Void
        }
        
        enum Style {

            case light
            case dark
            
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

enum AuthProductsViewModelAction {

    struct Dismiss: Action {}
}

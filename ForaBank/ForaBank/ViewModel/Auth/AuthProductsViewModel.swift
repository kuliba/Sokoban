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
    @Published var productCards: [ProductCardViewModel]
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    init(_ model: Model = .emptyMock, productCards: [ProductCardViewModel], dismissAction: @escaping () -> Void = {}) {

        self.navigationBar = NavigationBarViewModel(title: "Выберите продукт", action: dismissAction)
        self.productCards = productCards
        self.model = model
    }
    
    init(_ model: Model, products: [CatalogProductData], dismissAction: @escaping () -> Void = {}) {

        self.navigationBar = NavigationBarViewModel(title: "Выберите продукт", action: dismissAction)
    
        self.productCards = products.enumerated().map({ product in
            
            ProductCardViewModel(with: product.element, style: .init(number: product.offset))
        })
        self.model = model
        
        bind()
        self.model.action.send(ModelAction.Deposits.List.Request())
        requestImages(for: products)
    }
    
    init(_ model: Model, products: [DepositProductData], dismissAction: @escaping () -> Void = {}) {

        self.navigationBar = NavigationBarViewModel(title: "Выберите продукт", action: dismissAction)
    
        self.productCards = products.enumerated().map({ product in
            
            ProductCardViewModel(with: product.element, style: .init(number: product.offset))
        })
        self.model = model
        
        bind()
        self.model.action.send(ModelAction.Deposits.List.Request())
        requestDepositImages(for: products)
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.General.DownloadImage.Response:
                    switch payload.result {
                    case .success(let data):
      
                        guard let image = Image(data: data) else {
                            //TODO: set logger
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
                        break
                        //TODO: set logger
                    }
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func requestImages(for products: [CatalogProductData]) {
        
        for product in products {
        
            model.action.send(ModelAction.General.DownloadImage.Request(endpoint: product.imageEndpoint))
        }
    }
    
    func requestDepositImages(for products: [DepositProductData]) {
        
        for product in products {
        
            //FIXME: - posible wrong
            model.action.send(ModelAction.General.DownloadImage.Request(endpoint: product.generalСondition.imageLink))
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
    
    class ProductCardViewModel: Identifiable, ObservableObject {

        let id = UUID()
        let style: Style
        let title: String
        let subtitle: [String]
        @Published var image: ImageData
        let infoButton: InfoButton
        let orderButton: OrderButton
        let conditionViewModel: ConditionViewModel?
        
        internal init(style: Style, title: String, subtitle: [String], image: ImageData, infoButton: InfoButton, orderButton: OrderButton, conditionViewModel: ConditionViewModel) {
            
            self.style = style
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.infoButton = infoButton
            self.orderButton = orderButton
            self.conditionViewModel = conditionViewModel
        }
        
        init(with product: CatalogProductData, style: Style) {
            
            self.style = style
            self.title = product.name
            self.subtitle = product.description
            self.conditionViewModel = nil
            self.image = .endpoint(product.imageEndpoint)
            self.infoButton = InfoButton(url: product.infoURL)
            self.orderButton = OrderButton(url: product.orderURL)
        }
        
        init(with deposit: DepositProductData, style: Style) {
            self.style = style
            self.title = deposit.name
            self.conditionViewModel = .init(percent: "\(deposit.generalСondition.maxSum)", amount: "\(deposit.generalСondition.minSum)", date: "\(deposit.generalСondition.minTerm)")
            self.subtitle = deposit.generalСondition.generalTxtСondition
            self.image = .endpoint(deposit.generalСondition.imageLink)
            self.infoButton = .init(url: .init(string: "https://www.forabank.ru")!)
            self.orderButton = OrderButton(url: .init(string: "https://www.forabank.ru")!)
            
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
        
        struct ConditionViewModel {
            
            let percent: String
            let amount: String
            let date: String
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

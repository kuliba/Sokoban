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
    
    convenience init(_ model: Model, products: [CatalogProductData], action: @escaping (_ id: Int) -> Void, dismissAction: @escaping () -> Void) {
        
        let productCards = products.enumerated().map {
            
            ProductCardViewModel(
                with: $0.element,
                style: .init(number: $0.offset),
                action: action
            )
        }
        
        self.init(model, productCards: productCards, dismissAction: dismissAction)
        
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
        
        model.sessionState
            .sink {[unowned self] state in
                
                switch state {
                case .expired, .inactive:
                    model.action.send(ModelAction.Auth.Session.Start.Request())
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
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

        @Published var image: ImageData
        
        let id = UUID()
        let style: Style
        let title: String
        let subtitle: [String]
        let infoButton: InfoButton
        let orderButtonType: OrderButtonType
        let conditionViewModel: ConditionViewModel?
        
        init(style: Style, title: String, subtitle: [String], image: ImageData, infoButton: InfoButton, orderButtonType: OrderButtonType, conditionViewModel: ConditionViewModel?) {
            
            self.style = style
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.infoButton = infoButton
            self.orderButtonType = orderButtonType
            self.conditionViewModel = conditionViewModel
        }
        
        convenience init(with product: CatalogProductData, style: Style) {
            
            self.init(
                style: style,
                title: product.name,
                subtitle: product.description,
                image: .endpoint(product.imageEndpoint),
                infoButton: .init(url: product.infoURL),
                orderButtonType: .main(.init(url: product.orderURL)),
                conditionViewModel: nil
            )
        }
        
        convenience init(with product: CatalogProductData, style: Style, action: @escaping (_ id: Int) -> Void) {
            
            self.init(
                style: style,
                title: product.name,
                subtitle: product.description,
                image: .endpoint(product.imageEndpoint),
                infoButton: .init(url: product.infoURL),
                orderButtonType: .auth(.init(id: product.id, action: action)),
                conditionViewModel: nil
            )
        }
        
        convenience init(with deposit: DepositProductData, style: Style) {
            
            self.init(
                style: style,
                title: deposit.name,
                subtitle: deposit.generalСondition.generalTxtСondition,
                image: .endpoint(deposit.generalСondition.imageLink),
                infoButton: .init(url: .init(string: "https://www.forabank.ru")!),
                orderButtonType: .main(.init(url: .init(string: "https://www.forabank.ru")!)),
                conditionViewModel: .init(
                    percent: "\(deposit.generalСondition.maxSum)",
                    amount: "\(deposit.generalСondition.minSum)",
                    date: "\(deposit.generalСondition.minTerm)"
                )
            )
        }
        
        enum OrderButtonType {
        
            case main(OrderButton)
            case auth(OrderAuthButton)
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
        
        struct OrderAuthButton {

            let id: Int
            let title: String = "Заказать"
            let action: (_ id: Int) -> Void
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

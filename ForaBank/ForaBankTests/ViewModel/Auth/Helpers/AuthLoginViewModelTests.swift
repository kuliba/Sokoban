//
//  AuthLoginViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 23.09.2023.
//

import Combine
@testable import ForaBank
import LandingUIComponent
import SwiftUI
import XCTest

class AuthLoginViewModelTests: XCTestCase {
    
    typealias ClientInformMessage = PassthroughSubject<String, Never>
    typealias CheckClientResponse = PassthroughSubject<ModelAction.Auth.CheckClient.Response, Never>
    typealias CatalogProducts = PassthroughSubject<([CatalogProductData]), Never>
    typealias SessionStateFcmToken = PassthroughSubject<(SessionState, String?), Never>
    
    final class RootActionsSpy {
        
        private(set) var spinnerMessages = [Spinner]()
        
        func rootActions() -> RootViewModel.RootActions {
            
            .init(
                dismissCover: {},
                spinner: .init(
                    show: { [weak self] in
                        
                        self?.spinnerMessages.append(.show)
                    },
                    hide: { [weak self] in
                        
                        self?.spinnerMessages.append(.hide)
                    }
                ),
                switchTab: { _ in },
                dismissAll: {}
            )
        }
        
        enum Spinner {
            
            case hide, show
        }
    }
    
    final class RegisterCardNumberSpy {
        
        private(set) var values = [String]()
        
        func registerCardNumber(_ cardNumber: String) {
            
            values.append(cardNumber)
        }
    }
    
    final class AuthLoginViewModelFactorySpy: AuthLoginViewModelFactory {
       
        private let products: [CatalogProductData]
        
        init(products: [CatalogProductData]) {
            
            self.products = products
        }
        
        func makeAuthConfirmViewModel(
            confirmCodeLength: Int,
            phoneNumber: String,
            resendCodeDelay: TimeInterval,
            backAction: @escaping () -> Void
        ) -> AuthConfirmViewModel {
            
            let codeViewModel = AuthConfirmViewModel.CodeViewModel(
                title: "Введите код из сообщения",
                lenght: confirmCodeLength,
                state: .openening
            )
            let infoViewModel = AuthConfirmViewModel.InfoViewModel(
                title: phoneNumber,
                subtitle: "Повторно отправить можно через:",
                state: .button(.init(action: {}))
            )
            
            return .init(
                navigationBar: .init(action: backAction),
                code: codeViewModel,
                info: infoViewModel,
                isPincodeViewPresented: false,
                model: .emptyMock,
                showingAlert: false,
                phoneNumber: phoneNumber,
                resendCodeDelay: resendCodeDelay,
                backAction: {},
                rootActions: .emptyMock
            )
        }
        
        func makeAuthProductsViewModel(
            action: @escaping (Int) -> Void,
            dismissAction: @escaping () -> Void
        ) -> AuthProductsViewModel {
            
            .init(.emptyMock, products: products, action: action, dismissAction: dismissAction)
        }
        
        func makeOrderProductViewModel(
            productData: CatalogProductData
        ) -> OrderProductView.ViewModel {
            
            .init(.mockWithEmptyExcept(), productData: productData)
        }
        
        struct CardOrder: Equatable {
            let cardTarif, cardType: Int
        }
        
        private(set) var abroadType: AbroadType?
        private(set) var cardOrders = [CardOrder]()
        private(set) var stickerOrders = [Int]()
        private(set) var goToMainCount = 0
        private(set) var openUrl = 0

        
        func makeCardLandingViewModel(
            _ type: ForaBank.AbroadType,
            config: LandingUIComponent.UILanding.Component.Config,
            landingActions: @escaping (LandingUIComponent.LandingEvent.Card) -> () -> Void
        ) -> LandingUIComponent.LandingWrapperViewModel {
            
            self.abroadType = type
            
            let imagePublisher: LandingWrapperViewModel.ImagePublisher = {
                
                return Just(["1": .ic16Tv])
                    .eraseToAnyPublisher()
            }()
            
            return .init(
                statePublisher: Just(.success(.preview)).eraseToAnyPublisher(),
                imagePublisher: imagePublisher,
                imageLoader: { _ in },
                makeIconView: { _ in .init(
                    image: .cardPlaceholder,
                    publisher: Just(.cardPlaceholder).eraseToAnyPublisher()
                )},
                config: .default) { [weak self] event in
                    switch event {
                        
                    case let .card(card):
                        switch card {
                            
                        case .goToMain:
                            self?.goToMainCount += 1
                        case let .order(cardTarif, cardType):
                            self?.cardOrders.append(
                                .init(cardTarif: cardTarif, cardType: cardType)
                            )
                        case .openUrl:
                            self?.openUrl += 1
                        }
                        
                    case let .sticker(sticker):
                        switch sticker {
                            
                        case .goToMain:
                            self?.goToMainCount += 1
                        case .order:
                            self?.stickerOrders.append(1)
                        }
                    }
                }
        }
    }
}

// MARK: - DSL

extension AuthLoginViewModel {
    
    // MARK: - Properties
    
    func backButtonInConfirm(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> AuthConfirmViewModel.NavigationBarViewModel.BackButtonViewModel {
        
        try XCTUnwrap(
            link?.confirmViewModel?.navigationBar.backButton,
            "Expected to have navigation back button at confirm.",
            file: file, line: line
        )
    }
    
    // MARK: - Publishers
    
    var alertPublisher: AnyPublisher<Alert.ViewModel.View?, Never> {
        
        $alert
            .map(\.?.view)
            .eraseToAnyPublisher()
    }
    
    var registerCardNumber: AnyPublisher<String, Never> {
        
        action
            .compactMap {
                
                if case let .register(cardNumber: cardNumber) = $0 {
                    return cardNumber
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    var scannerPublisher: AnyPublisher<Spy?, Never> {
        
        $cardScanner.map {
            
            $0.map { _ in Spy.scanner } ?? nil
        }
        .eraseToAnyPublisher()
    }
    
    enum Spy: Equatable {
        
        case product
        case scanner
    }
    
    // MARK: - Actions
    
    func orderCard(cardTarif: Int, cardType: Int) {
        
        XCTAssertNotNil(link)
        link?.landingWrapperViewModel?.action(.card(.order(cardTarif: cardTarif, cardType: cardType)))
    }
    
    func goToMain() {
        
        XCTAssertNotNil(link)
        link?.landingWrapperViewModel?.action(.card(.goToMain))
    }
    
    // MARK: - Actions on scheduler
    
    func register(
        cardNumber: String,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        action.send(.register(cardNumber: cardNumber))
        scheduler.advance()
    }
    
    func showProductsAndWait(
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        showProducts()
        scheduler.advance()
    }
    
    func showTransfersAndWait(
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        showTransfers()
        scheduler.advance()
    }
    
    func showScanner(
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        action.send(.show(.scanner))
        scheduler.advance()
    }
    
    func closeScanner(
        _ scanValue: String?,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        cardScanner?.closeAction(scanValue)
        scheduler.advance()
    }
    
    func tapBackButtonInConfirm(
        on scheduler: TestSchedulerOfDispatchQueue,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let backButton = try backButtonInConfirm(file: file, line: line)
        backButton.action()
        scheduler.advance()
    }
    
    // MARK: - Actions & Wait
    
    func register(
        cardNumber: String,
        timeout: TimeInterval = 0.05
    ) {
        action.send(.register(cardNumber: cardNumber))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func showProductsAndWait(timeout: TimeInterval = 0.05) {
        
        showProducts()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func showTransfersAndWait(timeout: TimeInterval = 0.05) {
        
        showTransfers()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func showScanner(timeout: TimeInterval = 0.05) {
        
        action.send(.show(.scanner))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
    }
    
    func closeScanner(
        _ scanValue: String?,
        timeout: TimeInterval = 0.05
    ) {
        cardScanner?.closeAction(scanValue)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
    }
    
    func tapBackButtonInConfirm(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let backButton = try backButtonInConfirm(file: file, line: line)
        backButton.action()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
    }
    
    func tapAlertPrimaryButton(
        timeout: TimeInterval = 0.05
    ) {
        alert?.primary.action()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)

    }
}

// MARK: - Helpers

extension CatalogProductData {
    
    static let sample: Self = .init(
        name: "Sample",
        description: ["Sample", "Product"],
        imageEndpoint: "",
        infoURL: .init(string: "infoURL")!,
        orderURL: .init(string: "orderURL")!,
        tariff: 1,
        productType: 1
    )
}

extension ClientInformData {
    
    static let emptyAuthorized_nilNotAuthorized: Self = .init(
        serial: "serial",
        authorized: [],
        notAuthorized: nil
    )
    
    static let emptyAuthorized_notNilNotAuthorized: Self = .init(
        serial: "serial",
        authorized: [],
        notAuthorized: "notAuthorized"
    )
    
    static let notEmptyAuthorized_nilNotAuthorized: Self = .init(
        serial: "serial",
        authorized: ["authorized"],
        notAuthorized: nil
    )
    
    static let notEmptyAuthorized_notNilNotAuthorized: Self = .init(
        serial: "serial",
        authorized: ["authorized"],
        notAuthorized: "notAuthorized"
    )
}

extension AuthLoginViewModel.Link {
    
    var authProductsViewModel: AuthProductsViewModel? {
        
        if case let .products(authProductsViewModel) = self {
            return authProductsViewModel
        } else {
            return nil
        }
    }
    
    var landingWrapperViewModel: LandingWrapperViewModel? {
        
        if case let .landing(landingWrapperViewModel) = self {
            return landingWrapperViewModel
        } else {
            return nil
        }
    }
    
    var confirmViewModel: AuthConfirmViewModel? {
        
        if case let .confirm(confirmViewModel) = self {
            return confirmViewModel
        } else {
            return nil
        }
    }
    
    var `case`: Case {
        
        switch self {
        case let .confirm(viewModel):
            return .confirm(viewModel.view)
            
        case let .products(viewModel):
            return .products(titles: viewModel.productCards.map(\.title))
            
        case .landing:
            return .landing
        }
    }
    
    enum Case: Equatable {
        
        case confirm(AuthConfirmViewModel.View)
        case products(titles: [String])
        case landing
    }
}

extension AuthConfirmViewModel {
    
    var view: View {
        
        .init(
            codeTitle: code.title,
            codeLength: code.codeLenght,
            infoTitle: info?.title
        )
    }
    
    struct View: Equatable {
        
        let codeTitle: String
        let codeLength: Int
        let infoTitle: String?
    }
}

extension AuthConfirmViewModel.View {
    
    static let sample: Self = .init(
        codeTitle: "Введите код из сообщения",
        codeLength: 1,
        infoTitle: "123-456"
    )
    static let modelSample: Self = .init(
        codeTitle: "Введите код из сообщения",
        codeLength: 1,
        infoTitle: "Код отправлен на 123-456"
    )
}

extension ModelAction.Auth.CheckClient.Response {
    
    static let sample: Self = success(
        codeLength: 1,
        phone: "123-456",
        resendCodeDelay: 1
    )
}

extension Alert.ViewModel {
    
    var view: View {
        
        .init(
            title: title,
            message: message,
            primary: .init(
                kind: primary.type.kind,
                title: primary.title
            ),
            secondary: secondary.map {
                .init(
                    kind: $0.type.kind,
                    title: $0.title
                )
            }
        )
    }
    
    struct View: Equatable {
        
        let title: String
        let message: String?
        let primary: ButtonViewModel
        let secondary: ButtonViewModel?
        
        struct ButtonViewModel: Equatable {
            
            let kind: Kind
            let title: String
            
            enum Kind {
                
                case `default`
                case distructive
                case cancel
            }
            
            static let `default`: Self = .init(kind: .default, title: "Ok")
        }
        
        static func alert(
            title: String = "Ошибка",
            message: String,
            primary: ButtonViewModel = .default,
            secondary: ButtonViewModel? = nil
        ) -> Self {
            
            .init(title: title, message: message, primary: primary, secondary: secondary)
        }
    }
}

private extension Alert.ViewModel.ButtonViewModel.Kind {
    
    var kind: Alert.ViewModel.View.ButtonViewModel.Kind {
        
        switch self {
            
        case .default:     return .default
        case .distructive: return .distructive
        case .cancel:      return .cancel
        }
    }
}

extension Array where Element == CatalogProductData {
    
    static let sample: Self = [
        .sample
    ]
}

extension ButtonAuthView.ViewModel {
    
    var view: View {
        
        .init(
            id: id,
            title: title,
            subTitle: subTitle
        )
    }
    
    struct View: Equatable {
        
        let id: ButtonAuthView.ViewModel.ButtonType
        let title: String
        let subTitle: String
    }
}

extension ButtonAuthView.ViewModel.View {
    
    static let orderCard: Self = .init(
        id: .card,
        title: "Нет карты?",
        subTitle: "Доставим в любую точку"
    )
    static let transfer: Self = .init(
        id: .abroad,
        title: "Переводы за рубеж",
        subTitle: "Быстро и безопасно"
    )
}

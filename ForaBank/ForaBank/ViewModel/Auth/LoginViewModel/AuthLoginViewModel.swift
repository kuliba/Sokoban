//
//  AuthLoginViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 07.02.2022.
//

import Combine
import CombineSchedulers
import Foundation
import SwiftUI
import LandingUIComponent

class AuthLoginViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    let header: HeaderViewModel
    
    @Published var link: Link?
    @Published var bottomSheet: BottomSheet?
    
    @Published var cardScanner: CardScannerViewModel?
    @Published var alert: Alert.ViewModel?
    
    @Published var buttons: [ButtonAuthView.ViewModel]
    
    private let eventPublishers: EventPublishers
    private let eventHandlers: EventHandlers
    private let factory: AuthLoginViewModelFactory
    private let onRegister: () -> Void
    private var bindings = Set<AnyCancellable>()
    
    lazy var card: CardViewModel = CardViewModel(
        scanButton: .init(
            action: { [weak self] in
                
                self?.action.send(.show(.scanner))
            }
        ),
        textField: .init(
            masks: [.card, .account],
            regExp: "[0-9]",
            toolbar: .init(
                doneButton: .init(
                    isEnabled: true,
                    action: { UIApplication.shared.endEditing() }),
                closeButton: .init(
                    isEnabled: true,
                    action: { UIApplication.shared.endEditing() }))
        ),
        nextButton: nil,
        state: .editing
    )
    
    init(
        eventPublishers: EventPublishers,
        eventHandlers: EventHandlers,
        factory: AuthLoginViewModelFactory,
        onRegister: @escaping () -> Void,
        buttons: [ButtonAuthView.ViewModel] = [],
        scheduler: AnySchedulerOf<DispatchQueue> = .makeMain()
    ) {
        self.header = .init()
        self.buttons = buttons
        self.eventPublishers = eventPublishers
        self.eventHandlers = eventHandlers
        self.factory = factory
        self.onRegister = onRegister
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "initialized")
        
        bind(on: scheduler)
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
    
    func showTransfers() {
        handleLandingAction(.transfer)
    }
    
    func showProducts() {
        handleLandingAction(.orderCard)
    }
}

// MARK: - Factory

protocol AuthLoginViewModelFactory {
    
    func makeAuthConfirmViewModel(
        confirmCodeLength: Int,
        phoneNumber: String,
        resendCodeDelay: TimeInterval,
        backAction: @escaping () -> Void
    ) -> AuthConfirmViewModel
    
    func makeAuthProductsViewModel(
        action: @escaping (_ id: Int) -> Void,
        dismissAction: @escaping () -> Void
    ) -> AuthProductsViewModel
    
    func makeOrderProductViewModel(
        productData: CatalogProductData
    ) -> OrderProductView.ViewModel
    
    func makeCardLandingViewModel(
        _ type: AbroadType,
        config: UILanding.Component.Config,
        landingActions: @escaping (LandingEvent.Card) -> () -> Void
    ) -> LandingWrapperViewModel
}

protocol MainViewModelFactory {
    
    func makeStickerLandingViewModel(
        _ type: AbroadType,
        config: UILanding.Component.Config,
        landingActions: @escaping (LandingEvent.Sticker) -> () -> Void
    ) -> LandingWrapperViewModel
}

// MARK: Binding

private extension AuthLoginViewModel {
    
    func bind(
        on scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        action
            .receive(on: scheduler)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case let .register(cardNumber):
                    handleRegisterAction(cardNumber)
                    
                case let .show(show):
                    switch show {
                    case .products:
                        handleShowProductsAction()
                        
                    case .scanner:
                        handleShowScannerAction()
                        
                    case let .orderProduct(productData):
                        handleShowOrderProductAction(productData)
                    }
                    
                case .closeLink:
                    handleCloseLinkAction()
                }
            }
            .store(in: &bindings)
        
        eventPublishers.clientInformMessage
            .receive(on: scheduler)
            .sink { [weak self] message in
                
                self?.showClientInformAlert(withMessage: message)
            }
            .store(in: &bindings)
        
        eventPublishers.checkClientResponse
            .receive(on: scheduler)
            .sink { [weak self] payload in
                
                self?.handleCheckClientResponse(payload)
            }
            .store(in: &bindings)
        
        card.$state
            .combineLatest(eventPublishers.sessionStateFcmToken)
            .receive(on: scheduler)
            .sink { [weak self] output in
                
                guard let self else { return }
                
                let (cardState, (sessionState, fcmToken)) = output
                self.card.nextButton = self.makeCardNextButton(with: cardState, sessionState, fcmToken: fcmToken)
            }
            .store(in: &bindings)
        
        eventPublishers.catalogProducts
            .receive(on: scheduler)
            .sink { [weak self] catalogProducts in
                
                guard let self else { return }
                
                withAnimation {
                    
                    self.buttons = self.makeButtons(with: catalogProducts)
                }
            }
            .store(in: &bindings)
    }
    
    func handleCheckClientResponse(
        _ payload: ModelAction.Auth.CheckClient.Response
    ) {
        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.CheckClient.Response")
        
        eventHandlers.hideSpinner()
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "Call hide spinner rootAction")
        
        switch payload {
        case let .success(codeLength: codeLength, phone: phone, resendCodeDelay: resendCodeDelay):
            LoggerAgent.shared.log(category: .ui, message: "ModelAction.Auth.CheckClient.Response: success")
            
            let confirmViewModel = factory.makeAuthConfirmViewModel(
                confirmCodeLength: codeLength,
                phoneNumber: phone,
                resendCodeDelay: resendCodeDelay,
                backAction: { [weak self] in
                    
                    self?.action.send(.closeLink)
                }
            )
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented confirm view")
            link = .confirm(confirmViewModel)
            
        case .failure(message: let message):
            LoggerAgent.shared.log(category: .ui, message: "ModelAction.Auth.CheckClient.Response: failure message \(message)")
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "alert presented")
            alert = .init(
                title: "Ошибка",
                message: message,
                primary: .init(
                    type: .default,
                    title: "Ok",
                    action: { [weak self] in self?.alert = nil }
                )
            )
        }
    }
    
    func handleRegisterAction(
        _ cardNumber: String
    ) {
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Register")
        
        eventHandlers.onRegisterCardNumber(cardNumber)
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "dismiss keyboard")
        card.textField.dismissKeyboard()
        
        eventHandlers.showSpinner()
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "Call show spinner rootAction")
    }
    
    func orderCard(
        _ cardTarif: Int,
        _ cardType: Int
    ) {
        if let catalogProduct = self.eventHandlers.catalogProduct(.tarif(cardTarif, type: cardType)) {
            
            handleShowOrderProductAction(catalogProduct)
        }
    }
    
    func handleShowProductsAction() {
        
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Show.Products")
        
        let action: (Int) -> Void = { [weak self] id in
            
            guard let self = self else { return }
            
            if let catalogProduct = self.eventHandlers.catalogProduct(.id(id)) {
                
                self.action.send(.show(.orderProduct(catalogProduct)))
            }
        }
        
        let dismissAction: () -> Void = { [weak self] in
            
            self?.action.send(.closeLink)
        }
        
        let viewModel = factory.makeAuthProductsViewModel(
            action: action,
            dismissAction: dismissAction
        )
        
        UIApplication.shared.endEditing()
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented products view")
        link = .products(viewModel)
    }
    
    func handleLandingAction(_ abroadType: AbroadType) {
        
        let viewModel = factory.makeCardLandingViewModel(
            abroadType,
            config: .default,
            landingActions: landingAction
        )
        
        UIApplication.shared.endEditing()
        
        link = .landing(viewModel)
    }
    
    private func landingAction(for event: LandingEvent.Card) -> () -> Void {
        
            switch event {
            case .goToMain:
                return handleCloseLinkAction
                
             case let .order(cardTarif, cardType):
                return { [weak self] in
                    self?.orderCard(cardTarif, cardType) }
                
            }
    }
    
    func handleShowScannerAction() {
        
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Show.Scaner")
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented card scanner")
        
        cardScanner = .init(closeAction: { [weak self] value in
            
            guard let self else { return }
            
            if let value {
                
                let filteredValue = (try? value.filtered(regEx: self.card.textField.regExp)) ?? value
                let maskedValue = filteredValue.masked(masks: self.card.textField.masks)
                self.card.textField.text = maskedValue
            }
            
            self.cardScanner = nil
        })
    }
    
    func showClientInformAlert(
        withMessage message: String
    ) {
        LoggerAgent.shared.log(category: .ui, message: "AuthLoginViewModelAction.Show.AlertClientInform: \(message)")
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "alert ClientInform presented")
        
        alert = .init(
            title: "Ошибка",
            message: message,
            primary: .init(
                type: .default,
                title: "Ok",
                action: { [weak self] in self?.alert = nil }
            )
        )
    }
    
    func handleCloseLinkAction() {
        
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Close.Link")
        link = nil
    }
    
    func handleShowOrderProductAction(
        _ productData: CatalogProductData
    ) {
        let viewModel = factory.makeOrderProductViewModel(
            productData: productData
        )
        
        bottomSheet = .init(type: .orderProduct(viewModel))
    }
    
    func makeCardNextButton(
       with cardState: CardViewModel.State,
       _ sessionState: SessionState,
       fcmToken: String?
    ) -> CardViewModel.NextButtonViewModel? {
        
        switch (cardState, sessionState, fcmToken) {
        case (.ready(let cardNumber), .active, .some), (.ready(let cardNumber), .active, .none),
             (.ready(let cardNumber), .activating, .some), (.ready(let cardNumber), .activating, .none),
             (.ready(let cardNumber), .expired, .some), (.ready(let cardNumber), .expired, .none),
             (.ready(let cardNumber), .inactive, .some), (.ready(let cardNumber), .inactive, .none),
             (.ready(let cardNumber), .failed(_), .some), (.ready(let cardNumber), .failed(_), .none):
            
            LoggerAgent.shared.log(category: .ui, message: "card state: .ready, session state: \(sessionState.debugDescription)")
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "next button presented")
            
            return CardViewModel.NextButtonViewModel(
                action: { [weak self] in
                    
                    self?.onRegister()
                    self?.action.send(.register(cardNumber: cardNumber))
                })
            
        default:
            return nil
        }
    }
    
    func makeButtons(
        with catalogProducts: [CatalogProductData]
    ) -> [ButtonAuthView.ViewModel] {
        
        var buttons = [ButtonAuthView.ViewModel]()
        
        buttons.append(
            .init(.abroad) { [weak self] in self?.showTransfers() }
        )
        
        if !catalogProducts.isEmpty {
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "catalog products button presented")
            buttons.append(
                .init(.card) { [weak self] in self?.showProducts() }
            )
        }
        
        return buttons
    }
}

// MARK: - Types

extension AuthLoginViewModel {
    
    struct HeaderViewModel {
        
        let title = "Войти"
        let subTitle = "чтобы получить доступ к счетам и картам"
        let icon: Image = .ic16ArrowDown
    }
    
    class CardViewModel: ObservableObject {
        
        let icon: Image
        let scanButton: ScanButtonViewModel
        @Published var textField: TextFieldMaskableView.ViewModel
        @Published var nextButton: NextButtonViewModel?
        let subTitle: String
        @Published var state: State
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(icon: Image = .ic32LogoForaLine, scanButton: ScanButtonViewModel, textField: TextFieldMaskableView.ViewModel, nextButton: NextButtonViewModel? = nil, subTitle: String = "Введите номер вашей карты или счета", state: State = .editing) {
            
            self.icon = icon
            self.scanButton = scanButton
            self.textField = textField
            self.nextButton = nextButton
            self.subTitle = subTitle
            self.state = .editing
            
            bind()
        }
        
        private func bind() {
            
            textField.$text
                .receive(on: DispatchQueue.main)
                .sink { [weak self] text in
                    
                    guard let self,
                          let text = text
                    else { return }
                    
                    for mask in textField.masks {
                        
                        if text.isComplete(for: mask) {
                            
                            let unmasked = (try? text.filtered(regEx: textField.regExp)) ?? text
                            state = .ready(unmasked)
                            return
                        }
                    }
                    
                    state = .editing
                }
                .store(in: &bindings)
        }
        
        struct ScanButtonViewModel {
            
            let icon: Image = .ic24SkanCard
            let action: () -> Void
        }
        
        struct NextButtonViewModel {
            
            let icon: Image = .ic24ArrowRight
            let action: () -> Void
        }
        
        enum State: Hashable {
            
            case editing
            case ready(String)
        }
    }
    
    enum Link {
        
        case confirm(AuthConfirmViewModel)
        case landing(LandingWrapperViewModel)
        case products(AuthProductsViewModel)
    }
    
    struct BottomSheet: BottomSheetCustomizable {
        
        let id = UUID()
        let type: Kind
        
        var animationSpeed: Double { 0.4 }
        
        enum Kind {
            
            case orderProduct(OrderProductView.ViewModel)
        }
    }
}

// MARK: - Actions

extension AuthLoginViewModel {
    
    enum Action {
        
        case register(cardNumber: String)
        case show(Show)
        case closeLink
        
        enum Show {
            
            case orderProduct(CatalogProductData)
            case products
            case scanner
        }
    }
    
    struct EventPublishers {
        
        let clientInformMessage: AnyPublisher<String, Never>
        let checkClientResponse: AnyPublisher<ModelAction.Auth.CheckClient.Response, Never>
        let catalogProducts: AnyPublisher<([CatalogProductData]), Never>
        let sessionStateFcmToken: AnyPublisher<(SessionState, String?), Never>
    }
    
    struct EventHandlers {
        
        let onRegisterCardNumber: (String) -> Void
        let catalogProduct: (Request) -> CatalogProductData?
        let showSpinner: () -> Void
        let hideSpinner: () -> Void
        
        enum Request {
            
            case id(Int)
            case tarif(Int, type: Int)
        }
    }
}

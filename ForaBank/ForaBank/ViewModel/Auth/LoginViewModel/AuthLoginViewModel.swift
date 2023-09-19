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

class AuthLoginViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    let header: HeaderViewModel
    
    @Published var link: Link?
    @Published var bottomSheet: BottomSheet?
    
    @Published var cardScanner: CardScannerViewModel?
    @Published var alert: Alert.ViewModel?
    
    @Published var buttons: [ButtonAuthView.ViewModel]
    
    private let delayedAction: PassthroughSubject<DelayedAction, Never> = .init()
    private let eventPublishers: EventPublishers
    private let eventHandlers: EventHandlers
    private let factory: AuthLoginViewModelFactory
    private let rootActions: RootViewModel.RootActions
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
        buttons: [ButtonAuthView.ViewModel] = [],
        rootActions: RootViewModel.RootActions,
        scheduler: AnySchedulerOf<DispatchQueue> = .makeMain()
    ) {
        self.header = .init()
        self.buttons = buttons
        self.rootActions = rootActions
        self.eventPublishers = eventPublishers
        self.eventHandlers = eventHandlers
        self.factory = factory
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "initialized")
        
        bind(on: scheduler)
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
    
    func showTransfers() {
        
        action.send(.show(.transfers))
    }
    
    func showProducts() {
        
        action.send(.show(.products))
    }
}

// MARK: - Factory

protocol AuthLoginViewModelFactory {
    
    func makeAuthConfirmViewModel(
        confirmCodeLength: Int,
        phoneNumber: String,
        resendCodeDelay: TimeInterval,
        backAction: @escaping () -> Void,
        rootActions: RootViewModel.RootActions
    ) -> AuthConfirmViewModel
    
    func makeAuthProductsViewModel(
        action: @escaping (_ id: Int) -> Void,
        dismissAction: @escaping () -> Void
    ) -> AuthProductsViewModel
    
    func makeAuthTransfersViewModel(
        closeAction: @escaping () -> Void
    ) -> AuthTransfersViewModel
    
    func makeOrderProductViewModel(
        productData: CatalogProductData
    ) -> OrderProductView.ViewModel
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
                        
                    case .transfers:
                        handleShowTransfersAction(on: scheduler)
                        
                    case .scanner:
                        handleShowScannerAction()
                        
                    case let .orderProduct(productData):
                        handleShowOrderProductAction(productData)
                    }
                    
                case .closeLink:
                    handleCloseLinkAction()
                    
                case let .spinner(spinner):
                    switch spinner {
                    case .show: handleSpinnerShowAction()
                    case .hide: handleSpinnerHideAction()
                    }
                }
            }
            .store(in: &bindings)
        
        delayedAction
            .flatMap {
                
                Just($0.action)
                    .delay(
                        for: .milliseconds($0.delayMS),
                        scheduler: scheduler
                    )
            }
            .sink { [weak self] in
                
                self?.action.send($0)
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
        
        eventPublishers.catalogProductsTransferAbroad
            .receive(on: scheduler)
            .sink { [weak self] catalogProducts, transferAbroad in
                
                guard let self else { return }
                
                withAnimation {
                    
                    self.buttons = self.makeButtons(with: catalogProducts, and: transferAbroad)
                }
            }
            .store(in: &bindings)
    }
    
    func handleCheckClientResponse(
        _ payload: ModelAction.Auth.CheckClient.Response
    ) {
        LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.CheckClient.Response")
        
        action.send(.spinner(.hide))
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "sent AuthLoginViewModelAction.Spinner.Hide")
        
        switch payload {
        case let .success(codeLength: codeLength, phone: phone, resendCodeDelay: resendCodeDelay):
            LoggerAgent.shared.log(category: .ui, message: "ModelAction.Auth.CheckClient.Response: success")
            
            let confirmViewModel = factory.makeAuthConfirmViewModel(
                confirmCodeLength: codeLength,
                phoneNumber: phone,
                resendCodeDelay: resendCodeDelay,
                backAction: { [weak self] in
                    
                    self?.action.send(.closeLink)
                },
                rootActions: rootActions
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
        
        action.send(.spinner(.show))
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "sent AuthLoginViewModelAction.Spinner.Show")
    }
    
    func handleShowProductsAction() {
        
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Show.Products")
        
        let action: (Int) -> Void = { [weak self] id in
            
            guard let self = self else { return }
            
            if let catalogProduct = self.eventHandlers.catalogProductForID(id) {
                
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
    
    func handleShowTransfersAction(
        on scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        let viewModel = factory.makeAuthTransfersViewModel { [weak self] in
            
            self?.action.send(.closeLink)
        }
        
        UIApplication.shared.endEditing()
        
        bind(viewModel, on: scheduler)
        link = .transfers(viewModel)
    }
    
    func handleShowScannerAction() {
        
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Show.Scaner")
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented card scanner")
        
        cardScanner = .init(closeAction: { [weak self] value in
            
            guard let self else { return }
            
            if let value {
                
                let filterredValue = (try? value.filterred(regEx: self.card.textField.regExp)) ?? value
                let maskedValue = filterredValue.masked(masks: self.card.textField.masks)
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
    
    func handleSpinnerShowAction() {
        
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Spinner.Show")
        rootActions.spinner.show()
    }
    
    func handleSpinnerHideAction() {
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Spinner.Hide")
        rootActions.spinner.hide()
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
        case (.ready(let cardNumber), .active, .some):
            LoggerAgent.shared.log(category: .ui, message: "card state: .ready, session state: .active")
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "next button presented")
            
            return CardViewModel.NextButtonViewModel(
                action: { [weak self] in
                    
                    self?.action.send(.register(cardNumber: cardNumber))
                })
            
        default:
            return nil
        }
    }
    
    func makeButtons(
        with catalogProducts: [CatalogProductData],
        and transferAbroad: TransferAbroadResponseData?
    ) -> [ButtonAuthView.ViewModel] {
        
        var buttons = [ButtonAuthView.ViewModel]()
        
        if transferAbroad != nil {
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "TransferAbroad button presented")
            buttons.append(
                .init(.abroad) { [weak self] in self?.showTransfers() }
            )
        }
        
        if !catalogProducts.isEmpty {
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "catalog products button presented")
            buttons.append(
                .init(.card) { [weak self] in self?.showProducts() }
            )
        }
        
        return buttons
    }
    
    func bind(
        _ viewModel: AuthTransfersViewModel,
        on scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        viewModel.action
            .compactMap(\.transfersSectionAction)
            .receive(on: scheduler)
            .sink { [weak self] direction in
                
                guard let self else { return }
                
                switch direction {
                case .order:
                    self.action.send(.closeLink)
                    self.delayedAction.send(
                        .init(
                            delayMS: 1_000,
                            action: .show(.products)
                        )
                    )
                    
                case .transfers:
                    self.action.send(.closeLink)
                    
                case .tap:
                    break
                }
            }
            .store(in: &bindings)
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
                            
                            let unmasked = (try? text.filterred(regEx: textField.regExp)) ?? text
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
        case transfers(AuthTransfersViewModel)
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
        case spinner(Spinner)
        
        enum Show {
            
            case scanner
            case products
            case transfers
            case orderProduct(CatalogProductData)
        }
        
        enum Spinner {
            
            case show, hide
        }
    }
    
    struct DelayedAction {
        
        let delayMS: Int
        let action: Action
    }
    
    struct EventPublishers {
        
        let clientInformMessage: AnyPublisher<String, Never>
        let checkClientResponse: AnyPublisher<ModelAction.Auth.CheckClient.Response, Never>
        let catalogProductsTransferAbroad: AnyPublisher<([CatalogProductData], TransferAbroadResponseData?), Never>
        let sessionStateFcmToken: AnyPublisher<(SessionState, String?), Never>
    }
    
    struct EventHandlers {
        
        let onRegisterCardNumber: (String) -> Void
        let catalogProductForID: (Int) -> CatalogProductData?
    }
}

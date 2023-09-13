//
//  AuthLoginViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 07.02.2022.
//

import Foundation
import SwiftUI
import Combine

class AuthLoginViewModel: ObservableObject {
    
    let action: PassthroughSubject<AuthLoginViewModelAction, Never> = .init()
    let header: HeaderViewModel
    
    @Published var link: Link?
    @Published var bottomSheet: BottomSheet?
    
    @Published var cardScanner: CardScannerViewModel?
    @Published var alert: Alert.ViewModel?
    
    @Published var buttons: [ButtonAuthView.ViewModel]
    
    private let model: Model
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
                    action: { UIApplication.shared.endEditing()}),
                closeButton: .init(
                    isEnabled: true,
                    action: { UIApplication.shared.endEditing()}))
        ),
        nextButton: nil,
        state: .editing
    )
    
    init(
        header: HeaderViewModel = HeaderViewModel(),
        buttons: [ButtonAuthView.ViewModel],
        rootActions: RootViewModel.RootActions,
        model: Model = .emptyMock
    ) {
        self.header = header
        self.buttons = buttons
        self.rootActions = rootActions
        self.model = model
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "initialized")
    }
    
    convenience init(_ model: Model, rootActions: RootViewModel.RootActions) {
        
        self.init(buttons: [], rootActions: rootActions, model: model)
        bind()
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

private extension AuthLoginViewModel {
    
    func bind() {
        
        model.clientInform
            .receive(on: DispatchQueue.main)
            .sink { [weak self] clientInformData in
                
                guard let self else { return }
                
                guard !self.model.clientInformStatus.isShowNotAuthorized,
                      let message = clientInformData.data?.notAuthorized
                else { return }
                
                self.model.clientInformStatus.isShowNotAuthorized = true
                self.action.send(.show(.alertClientInform(message)))
            }
            .store(in: &bindings)
        
        model.action
            .compactMap { $0 as? ModelAction.Auth.CheckClient.Response }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
                
                self?.handleCheckClientResponse(payload)
            }
            .store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
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
                        handleShowTransfersAction()
                        
                    case .scanner:
                        handleShowScannerAction()
                        
                    case let .orderProduct(productData):
                        handleShowOrderProductAction(productData)
                        
                    case let .alertClientInform(payload):
                        extractShowAlertClientInformAction(payload)
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
        
        card.$state
            .combineLatest(model.sessionState, model.fcmToken)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cardState, sessionState, fcmToken in
                
                guard let self else { return }
                
                switch (cardState, sessionState, fcmToken) {
                case (.ready(let cardNumber), .active, .some):
                    LoggerAgent.shared.log(category: .ui, message: "card state: .ready, session state: .active")
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "next button presented")
                    card.nextButton = CardViewModel.NextButtonViewModel(
                        action: { [weak self] in
                            
                            self?.action.send(.register(cardNumber: cardNumber))
                        })
                    
                default:
                    card.nextButton = nil
                }
            }.store(in: &bindings)
        
        model.catalogProducts
            .combineLatest(model.transferAbroad)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] catalogProducts, transferAbroad in
                
                guard let self else { return }
                
                withAnimation {
                    
                    self.buttons = self.updateButtons(catalogProducts, transferAbroad)
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
            
            let confirmViewModel = AuthConfirmViewModel(
                model,
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
        
        LoggerAgent.shared.log(category: .ui, message: "send ModelAction.Auth.CheckClient.Request number: ...\(cardNumber.suffix(4))")
        model.action.send(ModelAction.Auth.CheckClient.Request(number: cardNumber))
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "dismiss keyboard")
        card.textField.dismissKeyboard()
        
        self.action.send(.spinner(.show))
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "sent AuthLoginViewModelAction.Spinner.Show")
    }
    
    func handleShowProductsAction() {
        
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Show.Products")
        
        let action: (Int) -> Void = { [weak self] id in
            
            guard let self = self else { return }
            
            if let catalogProduct = self.model.catalogProducts.value.first(where: { $0.id == id }) {
                
                self.action.send(.show(.orderProduct(catalogProduct)))
            }
        }
        
        let dismissAction: () -> Void = { [weak self] in
            
            self?.action.send(.closeLink)
        }
        
        let viewModel = AuthProductsViewModel(
            model,
            products: model.catalogProducts.value,
            action: action,
            dismissAction: dismissAction
        )
        
        UIApplication.shared.endEditing()
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented products view")
        link = .products(viewModel)
    }
    
    func handleShowTransfersAction() {
        
        let viewModel: AuthTransfersViewModel = .init(model) { [weak self] in
            
            self?.action.send(.closeLink)
        }
        
        UIApplication.shared.endEditing()
        
        bind(viewModel)
        link = .transfers(viewModel)
    }
    
    func handleShowScannerAction() {
        
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Show.Scaner")
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented card scanner")
        cardScanner = .init(closeAction: { [weak self] number in
            
            guard let self else { return }
            
            guard let value = number else {
                self.cardScanner = nil
                return
            }
            let filterredValue = (try? value.filterred(regEx: self.card.textField.regExp)) ?? value
            let maskedValue = filterredValue.masked(masks: self.card.textField.masks)
            self.card.textField.text = maskedValue
            self.cardScanner = nil
        })
    }
    
    func extractShowAlertClientInformAction(
        _ message: String
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
        let viewModel: OrderProductView.ViewModel = .init(
            model,
            productData: productData
        )
        
        bottomSheet = .init(type: .orderProduct(viewModel))
    }
    
    func updateButtons(
        _ catalogProducts: [CatalogProductData],
        _ transferAbroad: TransferAbroadResponseData?
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
    
    func bind(_ viewModel: AuthTransfersViewModel) {
        
        viewModel.action
            .compactMap(\.transfersSectionAction)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] direction in
                
                guard let self else { return }
                
                switch direction {
                case .order:
                    self.action.send(.closeLink)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                        
                        self?.action.send(.show(.products))
                    }
                    
                case .transfers:
                    self.action.send(.closeLink)
                    
                case .tap:
                    break
                }
            }
            .store(in: &bindings)
    }
}

//MARK: - Types

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

enum AuthLoginViewModelAction {
    
    case register(cardNumber: String)
    case show(Show)
    case closeLink
    case spinner(Spinner)
    
    enum Show {
        
        case scanner
        case products
        case transfers
        case orderProduct(CatalogProductData)
        case alertClientInform(String)
    }
    
    enum Spinner {
        
        case show, hide
    }
}

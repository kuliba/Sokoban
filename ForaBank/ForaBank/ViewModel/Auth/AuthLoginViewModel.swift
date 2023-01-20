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

    let action: PassthroughSubject<Action, Never> = .init()
    let header: HeaderViewModel
    
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var bottomSheet: BottomSheet?
    @Published var isLinkActive: Bool = false
    
    @Published var cardScanner: CardScannerViewModel?
    @Published var alert: Alert.ViewModel?
    
    @Published var buttons: [ButtonAuthView.ViewModel]
    
    private let model: Model
    private let rootActions: RootViewModel.RootActions
    private var bindings = Set<AnyCancellable>()

    lazy var card: CardViewModel = CardViewModel(scanButton: .init(action: {[weak self] in self?.action.send(AuthLoginViewModelAction.Show.Scaner()) }), textField: .init(masks: [.card, .account], regExp: "[0-9]"), nextButton: nil, state: .editing)
    
    private lazy var abroadButton: ButtonAuthView.ViewModel = .init(.abroad) { [weak self] in
        self?.action.send(AuthLoginViewModelAction.Show.Transfers())
    }
    
    private lazy var cardButton: ButtonAuthView.ViewModel = .init(.card) { [weak self] in
        self?.action.send(AuthLoginViewModelAction.Show.Products())
    }

    init(header: HeaderViewModel = HeaderViewModel(),
         buttons: [ButtonAuthView.ViewModel],
         rootActions: RootViewModel.RootActions,
         model: Model = .emptyMock) {

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
    
    private func bind() {

        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Auth.CheckClient.Response:
                    LoggerAgent.shared.log(category: .ui, message: "received ModelAction.Auth.CheckClient.Response")
                    
                    self.action.send(AuthLoginViewModelAction.Spinner.Hide())
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "sent AuthLoginViewModelAction.Spinner.Hide")
                    
                    switch payload {
                    case .success(codeLength: let codeLength, phone: let phone, resendCodeDelay: let resendCodeDelay):
                        LoggerAgent.shared.log(category: .ui, message: "ModelAction.Auth.CheckClient.Response: success")
                        
                        let confirmViewModel = AuthConfirmViewModel(model, confirmCodeLength: codeLength, phoneNumber: phone, resendCodeDelay: resendCodeDelay, backAction: { [weak self] in self?.action.send(AuthLoginViewModelAction.Close.Link())}, rootActions: rootActions)
                        
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented confirm view")
                        link = .confirm(confirmViewModel)
     
                    case .failure(message: let message):
                        LoggerAgent.shared.log(category: .ui, message: "ModelAction.Auth.CheckClient.Response: failure message \(message)")
                        
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "alert presented")
                        alert = .init(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: {[weak self] in self?.alert = nil }))
                        
                    }
    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as AuthLoginViewModelAction.Register:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Register")
                    
                    LoggerAgent.shared.log(category: .ui, message: "send ModelAction.Auth.CheckClient.Request number: ...\(payload.cardNumber.suffix(4))")
                    model.action.send(ModelAction.Auth.CheckClient.Request(number: payload.cardNumber))
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "dismiss keyboard")
                    card.textField.dismissKeyboard()
                    
                    self.action.send(AuthLoginViewModelAction.Spinner.Show())
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "sent AuthLoginViewModelAction.Spinner.Show")
                    
                case _ as AuthLoginViewModelAction.Show.Products:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Show.Products")
                    
                    let action: (Int) -> Void = { [weak self] id in
                        
                        guard let self = self else { return }
                        
                        if let catalogProduct = self.model.catalogProducts.value.first(where: { $0.id == id }) {
                            self.action.send(AuthLoginViewModelAction.Show.OrderProduct(productData: catalogProduct))
                        }
                    }
                    
                    let dismissAction: () -> Void = { [weak self] in
                        self?.action.send(AuthLoginViewModelAction.Close.Link())
                    }
                    
                    let viewModel: AuthProductsViewModel = .init(model, products: model.catalogProducts.value, action: action, dismissAction: dismissAction)
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented products view")
                    link = .products(viewModel)
                    
                case _ as AuthLoginViewModelAction.Show.Transfers:
                    
                    let viewModel: AuthTransfersViewModel = .init(model) { [weak self] in
                        self?.action.send(AuthLoginViewModelAction.Close.Link())
                    }
                    
                    bind(viewModel)
                    link = .transfers(viewModel)
                    
                case _ as AuthLoginViewModelAction.Show.Scaner:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Show.Scaner")
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented card scanner")
                    cardScanner = .init(closeAction: { number in
                        guard let value = number else {
                            self.cardScanner = nil
                            return
                        }
                        let filterredValue = (try? value.filterred(regEx: self.card.textField.regExp)) ?? value
                        let maskedValue = filterredValue.masked(masks: self.card.textField.masks)
                        self.card.textField.text = maskedValue
                        self.cardScanner = nil
                    })
                    
                case _ as AuthLoginViewModelAction.Close.Link:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Close.Link")
                    link = nil
                    
                case _ as AuthLoginViewModelAction.Spinner.Show:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Spinner.Show")
                    rootActions.spinner.show()
                    
                case _ as AuthLoginViewModelAction.Spinner.Hide:
                    LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Spinner.Hide")
                    rootActions.spinner.hide()
                    
                case let payload as AuthLoginViewModelAction.Show.OrderProduct:
                    
                    let viewModel: OrderProductView.ViewModel = .init(
                        model,
                        productData: payload.productData
                    )
                    
                    bottomSheet = .init(type: .orderProduct(viewModel))
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
                
        card.$state
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] cardState in
                
                guard case .ready(let cardNumber) = cardState else {
                    
                    card.nextButton = nil
                    return
                }
                LoggerAgent.shared.log(category: .ui, message: "card state: .ready")
                
                LoggerAgent.shared.log(level: .debug, category: .ui, message: "next button presented")
                card.nextButton = CardViewModel.NextButtonViewModel(action: {[weak self] in self?.action.send(AuthLoginViewModelAction.Register(cardNumber: cardNumber))})
                
            }.store(in: &bindings)
        
        model.catalogProducts
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] catalogProducts in
                
                if catalogProducts.count > 0 {
                    
                    if !self.buttons.contains(where: {$0.id == .card}) {
                        
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "catalog products button presented")
                        withAnimation {
                            self.buttons.append(self.cardButton)
                        }
                    }

                } else {
                    
                    for (index, button) in self.buttons.enumerated() {
                        if button.id == .card {
                            
                            LoggerAgent.shared.log(level: .debug, category: .ui, message: "catalog products button dismissed")
                            withAnimation {
                                let _ = self.buttons.remove(at: index)
                            }
                        }
                    }
                }
                
            }.store(in: &bindings)
        
        model.transferAbroad
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] jsonTransferAbroad in
                
                if jsonTransferAbroad != nil {
                    
                    if !self.buttons.contains(where: {$0.id == .abroad}) {
                        
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "TransferAbroad button presented")
                        withAnimation {
                            self.buttons.insert(self.abroadButton, at: 0)
                        }
                    }

                } else {
                    
                    for (index, button) in self.buttons.enumerated() {
                        if button.id == .abroad {
                            
                            LoggerAgent.shared.log(level: .debug, category: .ui, message: "TransferAbroad button dismissed")
                            withAnimation {
                                let _ = self.buttons.remove(at: index)
                            }
                        }
                    }
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ viewModel: AuthTransfersViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { action in
                
                switch action {
                    
                case _ as TransfersSectionAction.Direction.Detail.Order.Tap:
                    
                    self.action.send(AuthLoginViewModelAction.Close.Link())
    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.action.send(AuthLoginViewModelAction.Show.Products())
                    }
                    
                case _ as TransfersSectionAction.Direction.Detail.Transfers.Tap:
                    self.action.send(AuthLoginViewModelAction.Close.Link())
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
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
                .sink { [unowned self] text in
                    
                    guard let text = text else {
                        return
                    }
                    
                    for mask in textField.masks {
                        
                        if text.isComplete(for: mask) {
                            
                            let unmasked = (try? text.filterred(regEx: textField.regExp)) ?? text
                            state = .ready(unmasked)
                            return
                        }
                    }
                    
                    state = .editing
                    
                }.store(in: &bindings)
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

//MARK: - Actions

enum AuthLoginViewModelAction {

    struct Register: Action {

        let cardNumber: String
    }

    enum Show {

        struct Scaner: Action { }
        
        struct Products: Action { }
        
        struct Transfers: Action { }
        
        struct OrderProduct: Action {
            
            let productData: CatalogProductData
        }
    }
    
    enum Close {
        
        struct Link: Action {}
    }
    
    enum Spinner {
    
        struct Show: Action {}
        
        struct Hide: Action {}
    }
}


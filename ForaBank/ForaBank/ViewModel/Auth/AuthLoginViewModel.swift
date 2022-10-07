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
    lazy var card: CardViewModel = CardViewModel(scanButton: .init(action: {[weak self] in self?.action.send(AuthLoginViewModelAction.Show.Scaner()) }), textField: .init(masks: [.card, .account], regExp: "[0-9]"), nextButton: nil, state: .editing)
    
    let products: ProductsViewModel

    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    
    @Published var cardScanner: CardScannerViewModel?
    @Published var alert: Alert.ViewModel?
    
    private let rootActions: RootViewModel.RootActions
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    init(header: HeaderViewModel = HeaderViewModel(), products: ProductsViewModel, rootActions: RootViewModel.RootActions, model: Model = .emptyMock) {

        self.header = header
        self.products = products
        self.rootActions = rootActions
        self.model = model
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "initialized")
    }
    
    convenience init(_ model: Model, rootActions: RootViewModel.RootActions) {
        
        self.init(header: HeaderViewModel(), products: .init(button: nil), rootActions: rootActions, model: model)
        
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
                    
                    let productsViewModel = AuthProductsViewModel(model, products: model.catalogProducts.value, dismissAction: { [weak self] in self?.action.send(AuthLoginViewModelAction.Close.Link())})
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented products view")
                    link = .products(productsViewModel)
                    
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
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "catalog products button presented")
                    
                    withAnimation {
                        products.button = .init(action: { self.action.send(AuthLoginViewModelAction.Show.Products()) })
                    }


                } else {
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "catalog products button dismissed")
                    
                    withAnimation {
                        products.button = nil
                    }
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

    class ProductsViewModel: ObservableObject {
        
        @Published var button: ButtonViewModel?
        
        init(button: ButtonViewModel?) {
            
            self.button = button
        }

        struct ButtonViewModel {
            
            let icon: Image = .ic40Card
            let title = "Нет карты?"
            let subTitle = "Доставим в любую точку"
            let arrowRight: Image = .ic24ArrowRight
            let action: () -> Void
        }
    }
    
    enum Link {
        
        case confirm(AuthConfirmViewModel)
        case products(AuthProductsViewModel)
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
    }
    
    enum Close {
        
        struct Link: Action {}
    }
    
    enum Spinner {
    
        struct Show: Action {}
        
        struct Hide: Action {}
    }
}


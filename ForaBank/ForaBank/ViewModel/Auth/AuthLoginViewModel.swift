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
    }
    
    init(_ model: Model, rootActions: RootViewModel.RootActions) {
        
        self.model = model
        self.header = HeaderViewModel()
        self.products = .init(button: nil)
        self.rootActions = rootActions
        
        bind()
    }
    
    private func bind() {
        
        print("SessionAgent: AuthLoginViewModel BIND addr:\(Unmanaged.passUnretained(self).toOpaque())")

        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Auth.CheckClient.Response:
                    self.action.send(AuthLoginViewModelAction.Spinner.Hide())
                    switch payload {
                    case .success(codeLength: let codeLength, phone: let phone, resendCodeDelay: let resendCodeDelay):
                        let confirmViewModel = AuthConfirmViewModel(model, confirmCodeLength: codeLength, phoneNumber: phone, resendCodeDelay: resendCodeDelay, backAction: { [weak self] in self?.action.send(AuthLoginViewModelAction.Close.Link())}, rootActions: rootActions)
                        link = .confirm(confirmViewModel)
                        
                        print("SessionAgent: CHECK DONE")
                        
                    case .failure(message: let message):
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
                    model.action.send(ModelAction.Auth.CheckClient.Request(number: payload.cardNumber))
                    card.textField.dismissKeyboard()
                    self.action.send(AuthLoginViewModelAction.Spinner.Show())
                    print("SessionAgent: CHECK CLIENT")
                    
                case _ as AuthLoginViewModelAction.Show.Products:
                    let productsViewModel = AuthProductsViewModel(model, products: model.catalogProducts.value, dismissAction: { [weak self] in self?.action.send(AuthLoginViewModelAction.Close.Link())})
                    link = .products(productsViewModel)
                    
                case _ as AuthLoginViewModelAction.Show.Scaner:
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
                    link = nil
                    
                case _ as AuthLoginViewModelAction.Spinner.Show:
                    rootActions.spinner.show()
                    
                case _ as AuthLoginViewModelAction.Spinner.Hide:
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
                
                card.nextButton = CardViewModel.NextButtonViewModel(action: {[weak self] in self?.action.send(AuthLoginViewModelAction.Register(cardNumber: cardNumber))})
                
            }.store(in: &bindings)
        
        model.catalogProducts
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] catalogProducts in
                
                if catalogProducts.count > 0 {
                    
                    withAnimation {
                        products.button = .init(action: { self.action.send(AuthLoginViewModelAction.Show.Products()) })
                    }

                } else {
                    
                    withAnimation {
                        products.button = nil
                    }
                }
                
            }.store(in: &bindings)
    }
    
    deinit {
        
        print("SessionAgent: AuthLoginViewModel DEINIT")
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


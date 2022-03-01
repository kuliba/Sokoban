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
    lazy var card: CardViewModel = CardViewModel(scanButton: .init(action: { self.action.send(AuthLoginViewModelAction.Show.Scaner()) }), textField: .init(masks: [.card, .account], regExp: "[0-9]"), nextButton: nil, state: .editing)
    
    @Published var productsButton: ProductsButtonViewModel?
    
    @Published var isConfirmViewPresented: Bool
    var confirmViewModel: AuthConfirmViewModel?
    
    @Published var isProductsViewPresented: Bool
    var productsViewModel: AuthProductsViewModel?
    
    @Published var cardScanner: AuthCardScannerViewModel?
    @Published var alert: Alert.ViewModel?
    
    private let rootActions: RootViewModel.AuthActions
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    init(header: HeaderViewModel = HeaderViewModel(), productsButton: ProductsButtonViewModel? = nil,  isConfirmViewPresented: Bool = false, isProductsViewPresented: Bool = false, rootActions: RootViewModel.AuthActions, model: Model = .emptyMock) {

        self.header = header
        self.productsButton = productsButton
        self.isConfirmViewPresented = isConfirmViewPresented
        self.isProductsViewPresented = isProductsViewPresented
        self.rootActions = rootActions
        self.model = model
    }
    
    init(_ model: Model, rootActions: RootViewModel.AuthActions) {
        
        self.model = model
        self.header = HeaderViewModel()
        self.isConfirmViewPresented = false
        self.isProductsViewPresented = false
        self.rootActions = rootActions
        
        bind()
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Auth.Register.Response:
                    self.action.send(AuthLoginViewModelAction.Spinner.Hide())
                    switch payload {
                    case .success(codeLength: let codeLength, phone: let phone, resendCodeDelay: let resendCodeDelay):
                        confirmViewModel = AuthConfirmViewModel(model, confirmCodeLength: codeLength, phoneNumber: phone, resendCodeDelay: resendCodeDelay, backAction: { [weak self] in self?.action.send(AuthLoginViewModelAction.Dismiss.Confirm())}, rootActions: rootActions)
                        isConfirmViewPresented = true
                        
                    case .fail(message: let message):
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
                    model.action.send(ModelAction.Auth.Register.Request(number: payload.cardNumber))
                    card.textField.dismissKeyboard()
                    self.action.send(AuthLoginViewModelAction.Spinner.Show())
                    
                case _ as AuthLoginViewModelAction.Show.Products:
                    productsViewModel = AuthProductsViewModel(model, products: model.catalogProducts.value, dismissAction: { [weak self] in self?.action.send(AuthLoginViewModelAction.Dismiss.Products())})
                    isProductsViewPresented = true
                    
                case _ as AuthLoginViewModelAction.Show.Scaner:
                    cardScanner = .init(scannedAction: { [weak self] value in
                        
                        guard let self = self else {
                            return
                        }
                        
                        let filterredValue = (try? value.filterred(regEx: self.card.textField.regExp)) ?? value
                        let maskedValue = filterredValue.masked(masks: self.card.textField.masks)
                        self.card.textField.text = maskedValue
                        self.cardScanner = nil
                        
                    }, dismissAction: { [weak self] in self?.cardScanner = nil })
                    
                case _ as AuthLoginViewModelAction.Dismiss.Confirm:
                    confirmViewModel = nil
                    isConfirmViewPresented = false
                    
                case _ as AuthLoginViewModelAction.Dismiss.Products:
                    productsViewModel = nil
                    isProductsViewPresented = false
                    
                case _ as AuthLoginViewModelAction.Spinner.Show:
                    rootActions.spinner.show()
                    
                case _ as AuthLoginViewModelAction.Spinner.Hide:
                    rootActions.spinner.hide()
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        card.$state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                switch state {
                case .ready(let cardNumber):
                    card.nextButton = CardViewModel.NextButtonViewModel(action: {[weak self] in self?.action.send(AuthLoginViewModelAction.Register.init(cardNumber: cardNumber))})
                    
                case .editing:
                    card.nextButton = nil
                }
                
            }.store(in: &bindings)
        
        model.catalogProducts
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] catalogProducts in
                
                if catalogProducts.count > 0 {
                    
                    productsButton = ProductsButtonViewModel(action: { self.action.send(AuthLoginViewModelAction.Show.Products()) })
                    
                } else {
                    
                    productsButton = nil
                }
                
            }.store(in: &bindings)
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
        
        enum State {
            
            case editing
            case ready(String)
        }
    }

    struct ProductsButtonViewModel {

        let icon: Image = .ic40Card
        let title = "Нет карты?"
        let subTitle = "Доставим в любую точку"
        let arrowRight: Image = .ic24ArrowRight
        let action: () -> Void
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
    
    enum Dismiss {
        
        struct Confirm: Action {}
        
        struct Products: Action { }
    }
    
    enum Spinner {
    
        struct Show: Action {}
        
        struct Hide: Action {}
    }
}


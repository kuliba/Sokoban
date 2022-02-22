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
    
    @Published var alert: Alert.ViewModel?
    
    private let dismissAction: () -> Void
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    init(header: HeaderViewModel = HeaderViewModel(), productsButton: ProductsButtonViewModel? = nil,  isConfirmViewPresented: Bool = false, isProductsViewPresented: Bool = false, dismissAction: @escaping () -> Void, model: Model = .emptyMock) {

        self.header = header
        self.productsButton = productsButton
        self.isConfirmViewPresented = isConfirmViewPresented
        self.isProductsViewPresented = isProductsViewPresented
        self.dismissAction = dismissAction
        self.model = model
    }
    
    init(_ model: Model, dismissAction: @escaping () -> Void) {
        
        self.model = model
        self.header = HeaderViewModel()
        self.isConfirmViewPresented = false
        self.isProductsViewPresented = false
        self.dismissAction = dismissAction
        
        bind()
        
        //FIXME: REMOVE AFTER TESTS
        model.action.send(ModelAction.Auth.ProductsReady())
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Auth.Register.Response:
                    switch payload {
                    case .correct(codeLength: let codeLength, phone: let phone, resendCodeDelay: let resendCodeDelay):
                        confirmViewModel = AuthConfirmViewModel(model, confirmCodeLength: codeLength, phoneNumber: phone, resendCodeDelay: resendCodeDelay, backAction: { [weak self] in self?.action.send(AuthLoginViewModelAction.Dismiss.Confirm())}, dismissAction: dismissAction)
                        isConfirmViewPresented = true
                        
                    case .incorrect(message: let message):
                        alert = .init(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: {[weak self] in self?.alert = nil }))
                        break
                        
                    case .error(let error):
                        //TODO: handle error
                        break
                    }
                    
                case let payload as ModelAction.Auth.Logout.Response:
                    switch payload {
                    case .success:
                        isConfirmViewPresented = false
                        confirmViewModel = nil
                        card.textField.text = nil
                        
                    case .error(let error):
                        //TODO: handle error
                        break
                    }
                    
                case _ as ModelAction.Auth.ProductsReady:
                    productsButton = ProductsButtonViewModel(action: { self.action.send(AuthLoginViewModelAction.Show.Products()) })
    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as AuthLoginViewModelAction.Auth:
                    model.action.send(ModelAction.Auth.Register.Request(cardNumber: payload.cardNumber))
                    //TODO: start spinner here and block user taps
                    
                case _ as AuthLoginViewModelAction.Show.Products:
                    //TODO: load products from model:
                    //productsViewModel = AuthProductsViewModel(products: model.promoProducts)
                    productsViewModel = AuthProductsViewModel(productCards: AuthProductsViewModel.sampleProducts, dismissAction: { [weak self] in self?.action.send(AuthLoginViewModelAction.Dismiss.Products())})
                    isProductsViewPresented = true
                    
                case _ as AuthLoginViewModelAction.Show.Scaner:
                    //TODO: show scanner view here
                    break
                    
                case _ as AuthLoginViewModelAction.Dismiss.Confirm:
                    confirmViewModel = nil
                    isConfirmViewPresented = false
                    
                case _ as AuthLoginViewModelAction.Dismiss.Products:
                    productsViewModel = nil
                    isProductsViewPresented = false
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        card.$state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                switch state {
                case .ready(let cardNumber):
                    card.nextButton = CardViewModel.NextButtonViewModel(action: {[weak self] in self?.action.send(AuthLoginViewModelAction.Auth.init(cardNumber: cardNumber))})
                    
                case .editing:
                    card.nextButton = nil
                }
                
            }.store(in: &bindings)
        
    }
}

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

    struct Auth: Action {

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
}


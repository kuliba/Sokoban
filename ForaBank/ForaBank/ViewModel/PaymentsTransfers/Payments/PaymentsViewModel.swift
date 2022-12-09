//
//  PaymentsViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 14.03.2022.
//

import Foundation
import SwiftUI
import Combine

class PaymentsViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()

    @Published var content: ContentType
    @Published var successViewModel: PaymentsSuccessViewModel?
    @Published var spinner: SpinnerView.ViewModel?
    @Published var alert: Alert.ViewModel?
    
    let closeAction: () -> Void
    
    private let category: Payments.Category
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    enum ContentType {
        
        case service(PaymentsServiceViewModel)
        case operation(PaymentsOperationViewModel)
    }
    
    init(content: ContentType, category: Payments.Category, model: Model, closeAction: @escaping () -> Void) {
        
        self.content = content
        self.category = category
        self.model = model
        self.closeAction = closeAction
    }
    
    convenience init(category: Payments.Category, model: Model, closeAction: @escaping () -> Void) async throws {
        
        let result = try await model.paymentsService(for: category)
        switch result {
        case let .select(selectServiceParameter):
            // multiple services for category
            let serviceViewModel = PaymentsServiceViewModel(category: category, parameters: [selectServiceParameter], model: model)
            self.init(content: .service(serviceViewModel), category: category, model: model, closeAction: closeAction)
            serviceViewModel.rootActions = rootActions

        case let .selected(service):
            // single service for category
            let operation = try await model.paymentsOperation(with: service)
            let operationViewModel = PaymentsOperationViewModel(operation: operation, model: model, closeAction: closeAction)
            self.init(content: .operation(operationViewModel), category: category, model: model, closeAction: closeAction)
            operationViewModel.rootActions = rootActions
            bind(operationViewModel: operationViewModel)
        }
        
        bind()
    }
    
    convenience init(source: Payments.Operation.Source, model: Model, closeAction: @escaping () -> Void) async throws {
        
        let operation = try await model.paymentsOperation(with: source)
        guard let category = Payments.Category.category(for: operation.service) else {
            throw Error.unableRecognizeCategoryForService(operation.service)
        }
        let operationViewModel = PaymentsOperationViewModel(operation: operation, model: model, closeAction: closeAction)
        self.init(content: .operation(operationViewModel), category: category, model: model, closeAction: closeAction)
        operationViewModel.rootActions = rootActions
        bind(operationViewModel: operationViewModel)
        
        bind()
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.Payment.Process.Response:
                    self.action.send(PaymentsViewModelAction.Spinner.Hide())
                    
                    switch payload.result {
                    case let .complete(paymentSuccess):
                        let successViewModel = PaymentsSuccessViewModel(model, paymentSuccess: paymentSuccess)
                        self.successViewModel = successViewModel
                        bind(successViewModel: successViewModel)
                        // update products balances
                        model.action.send(ModelAction.Products.Update.Fast.All())
                        // update latest operations list
                        model.action.send(ModelAction.LatestPayments.List.Requested())
     
                    case let .failure(error):
                        switch error {
                        case let serverError as ServerAgentError:
                            switch serverError {
                            case let .serverStatus(.serverError, errorMessage: message):
                                guard let message = message else {
                                    return
                                }
                                
                                if message.contains("Введен некорректный код") {
                                    
                                    guard case .operation(let operationViewModel) = content else {
                                        return
                                    }
                                    
                                    operationViewModel.action.send(PaymentsOperationViewModelAction.IcorrectCodeEnterred())
                                    
                                } else if message.contains("Вы исчерпали") {
                                    
                                    self.action.send(PaymentsViewModelAction.AlertThenDismiss(message: message))
                                    
                                } else {
                                    
                                    self.action.send(PaymentsViewModelAction.Alert(message: message))
                                }

                            default:
                                self.action.send(PaymentsViewModelAction.Alert(message: error.localizedDescription))
                            }
                            
                        default:
                            self.action.send(PaymentsViewModelAction.Alert(message: error.localizedDescription))
                        }
                        
                    default:
                        break
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                    
                case _ as PaymentsViewModelAction.Dismiss:
                    withAnimation {
                        
                        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                    }
                    
                case _ as PaymentsViewModelAction.Spinner.Show:
                    withAnimation {
                        spinner = .init()
                    }
                    
                case _ as PaymentsViewModelAction.Spinner.Hide:
                    withAnimation {
                        spinner = nil
                    }
                    
                case let payload as PaymentsViewModelAction.Alert:
                    alert = .init(title: "Ошибка", message: payload.message, primary: .init(type: .default, title: "Ok", action: {}))
                    
                case let payload as PaymentsViewModelAction.AlertThenDismiss:
                    alert = .init(title: "Ошибка", message: payload.message, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.action.send(PaymentsViewModelAction.Dismiss())}))
 
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(successViewModel: PaymentsSuccessViewModel) {
        
        successViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsSuccessAction.Button.Close:
                    self.action.send(PaymentsViewModelAction.Dismiss())
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(operationViewModel: PaymentsOperationViewModel) {
        
        operationViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsOperationViewModelAction.CancelOperation:

                    //TODO: move to convenience init
                    let successViewModel = PaymentsSuccessViewModel(model, warningTitle: "Перевод отменен!", amount: payload.amount, iconType: .accepted, logo: .init(title: "сбп", image: .ic40Sbp), actionButton: .init(title: "На главный", style: .red, action: { [weak self] in
                        
                        self?.action.send(PaymentsViewModelAction.Dismiss())
                        
                    }), optionButtons: [])
                    self.successViewModel = successViewModel

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Types

extension PaymentsViewModel {
    
    struct RootActions {
        
        let dismiss: () -> Void
        let spinner: Spinner
        let alert: (String) -> Void
        
        struct Spinner {
            
            let show: () -> Void
            let hide: () -> Void
        }
    }
    
    var rootActions: RootActions {
        
        return .init(dismiss: { [weak self] in self?.action.send(PaymentsViewModelAction.Dismiss()) },
                     spinner:
                .init(show: { [weak self] in self?.action.send(PaymentsViewModelAction.Spinner.Show()) },
                      hide: { [weak self] in self?.action.send(PaymentsViewModelAction.Spinner.Hide()) }),
                     alert: { [weak self] message in self?.action.send(PaymentsViewModelAction.Alert(message: message)) })
    }
}

//MARK: - Action

enum PaymentsViewModelAction {
    
    struct Dismiss: Action {}
    
    enum Spinner {
        
        struct Show: Action {}
        struct Hide: Action {}
    }
    
    struct Alert: Action {
        
        let message: String
    }
    
    struct AlertThenDismiss: Action {
        
        let message: String
    }
}

extension PaymentsViewModel {
    
    enum Error: LocalizedError {
        case unableRecognizeCategoryForService(Payments.Service)
    }
}

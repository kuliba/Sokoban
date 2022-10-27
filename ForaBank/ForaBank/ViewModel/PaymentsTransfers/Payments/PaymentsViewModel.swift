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
            bind(serviceViewModel: serviceViewModel)

        case let .selected(service):
            // single service for category
            let operation = try await model.paymentsOperation(with: service)
            let operationViewModel = PaymentsOperationViewModel(model, operation: operation)
            self.init(content: .operation(operationViewModel), category: category, model: model, closeAction: closeAction)
            bind(operationViewModel: operationViewModel)
        }
        
        bind()
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.Payment.Continue.Response:
                    self.action.send(PaymentsViewModelAction.Spinner.Hide())
                    
                    switch payload.result {
                    case let .complete(paymentSuccess):
                        successViewModel = PaymentsSuccessViewModel(model, paymentSuccess: paymentSuccess, dismissAction: { [weak self] in self?.action.send(PaymentsViewModelAction.Dismiss())})
                        
                    case .failure(let errorMessage):
                        self.action.send(PaymentsViewModelAction.Alert(message: errorMessage))
                        
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
                    alert = .init(title: "Ошибка", message: payload.message, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.action.send(PaymentsViewModelAction.Dismiss())}))
 
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(serviceViewModel: PaymentsServiceViewModel) {
        
        serviceViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsServiceViewModelAction.Dismiss:
                    self.action.send(PaymentsViewModelAction.Dismiss())
                    
                case _ as PaymentsServiceViewModelAction.Spinner.Show:
                    self.action.send(PaymentsViewModelAction.Spinner.Show())
                    
                case _ as PaymentsServiceViewModelAction.Spinner.Hide:
                    self.action.send(PaymentsViewModelAction.Spinner.Hide())
                    
                case let payload as PaymentsServiceViewModelAction.Alert:
                    self.action.send(PaymentsViewModelAction.Alert(message: payload.message))
   
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
                case _ as PaymentsOperationViewModelAction.Dismiss:
                    self.action.send(PaymentsViewModelAction.Dismiss())
                    
                case _ as PaymentsOperationViewModelAction.Spinner.Show:
                    self.action.send(PaymentsViewModelAction.Spinner.Show())
                    
                case _ as PaymentsOperationViewModelAction.Spinner.Hide:
                    self.action.send(PaymentsViewModelAction.Spinner.Hide())
                    
                case let payload as PaymentsOperationViewModelAction.Alert:
                    self.action.send(PaymentsViewModelAction.Alert(message: payload.message))
   
                default:
                    break
                }
                
            }.store(in: &bindings)
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
}

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
        
        case idle
        case services(PaymentsServicesViewModel)
        case operation(PaymentsOperationViewModel)
    }
    
    init(content: ContentType, category: Payments.Category, model: Model, closeAction: @escaping () -> Void) {
        
        self.content = content
        self.category = category
        self.model = model
        self.closeAction = closeAction
    }
    
    convenience init(category: Payments.Category, model: Model, closeAction: @escaping () -> Void) {
        
        self.init(content: .idle, category: category, model: model, closeAction: closeAction)
        
        bind()
        model.action.send(ModelAction.Payment.Services.Request(category: category))
        action.send(PaymentsViewModelAction.Spinner.Show())
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.Payment.Services.Response:
                    self.action.send(PaymentsViewModelAction.Spinner.Hide())
                    
                    switch payload {
                    case .select(let selectServiceParameter):
                        // multiple services for category
                        let servicesViewModel = PaymentsServicesViewModel(model, category: category, parameter: selectServiceParameter, rootActions: rootActions)
                        content = .services(servicesViewModel)
                        
                    case .selected(let service):
                        // single service for category
                        model.action.send(ModelAction.Payment.Begin.Request(base: .service(service)))
                        
                    case .failed(let error):
                        self.action.send(PaymentsViewModelAction.Alert(message: error.localizedDescription))
                    }
                    
                case let payload as ModelAction.Payment.Begin.Response:
                    self.action.send(PaymentsViewModelAction.Spinner.Hide())
                    
                    switch payload {
                    case .success(let operation):
                        
                        guard case .idle = content else {
                            return
                        }
                        
                        let operationViewModel = PaymentsOperationViewModel(model, operation: operation, rootActions: rootActions)
                        content = .operation(operationViewModel)

                    case .failure(let errorMessage):
                        self.action.send(PaymentsViewModelAction.Alert(message: errorMessage))
                    }
                   
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
        
        .init(dismiss: { [weak self] in self?.action.send(PaymentsViewModelAction.Dismiss())},
              spinner: .init(show: { [weak self] in self?.action.send(PaymentsViewModelAction.Spinner.Show())},
                             hide: { [weak self] in self?.action.send(PaymentsViewModelAction.Spinner.Hide())}),
              alert: {[weak self] message in self?.action.send(PaymentsViewModelAction.Alert(message: message)) })
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

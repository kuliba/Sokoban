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
    
    private let category: Payments.Category
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    enum ContentType {
        
        case idle
        case services(PaymentsServicesViewModel)
        case operation(PaymentsOperationViewModel)
    }
    
    init(content: ContentType, category: Payments.Category = .taxes, model: Model = .emptyMock) {
        
        self.content = content
        self.category = category
        self.model = model
    }
    
    internal init(_ model: Model, category: Payments.Category) {
        
        self.content = .idle
        self.category = category
        self.model = model
        
        bind()
        model.action.send(ModelAction.Payment.Services.Request(category: category))
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.Payment.Services.Response:
                    switch payload {
                    case .select(let selectServiceParameter):
                        // multiple services for category
                        let servicesViewModel = PaymentsServicesViewModel(model, category: category, parameter: selectServiceParameter, dismissAction: { [weak self] in self?.action.send(PaymentsViewModelAction.Dismiss())})
                        content = .services(servicesViewModel)
                        
                    case .selected(let service):
                        // single service for category
                        model.action.send(ModelAction.Payment.Begin.Request(source: .service(service)))
                        
                    case .failed(let error):
                        print(error.localizedDescription)
                    }
                    
                case let payload as ModelAction.Payment.Begin.Response:
                    switch payload.result {
                    case .success(let operation):
                        
                        guard case .idle = content else {
                            return
                        }
                        
                        let operationViewModel = PaymentsOperationViewModel(model, operation: operation, dismissAction: { [weak self] in self?.action.send(PaymentsViewModelAction.Dismiss())})
                        content = .operation(operationViewModel)

                    case .failure(let error):
                        //TODO: log error
                        print(error.localizedDescription)
                    }
                    
                case let payload as ModelAction.Payment.Complete.Response:
                    switch payload.result {
                    case .success:
                        successViewModel = PaymentsSuccessViewModel(header: .init(stateIcon: Image("OkOperators"), title: "Успешный перевод", description: "1 000,00 ₽", operatorIcon: Image("Payments Service Sample")), optionButtons: [PaymentsSuccessOptionButtonView.ViewModel(id: UUID(), icon: Image("Payments Icon Success Star"),title: "Шаблон", action: {}),PaymentsSuccessOptionButtonView.ViewModel(id: UUID(), icon: Image("Payments Icon Success File"),title: "Документ", action: {}), PaymentsSuccessOptionButtonView.ViewModel(id: UUID(), icon: Image("Payments Icon Success Info"), title: "Детали", action: {})], actionButton: .init(title: "На главную", isEnabled: true, action: { [weak self] in self?.action.send(PaymentsViewModelAction.Dismiss())}))
                        
                        
                    case .failure:
                        print("Payments: continue fail")
                        break
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

enum PaymentsViewModelAction {
    
    struct Dismiss: Action {}
}

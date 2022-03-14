//
//  PaymentsViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 14.03.2022.
//

import Foundation
import Combine

class PaymentsViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var content: ContentType
    
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
                        break
                        // multiple services for category
//                        select = PaymentsSelectServiceView.ViewModel(with: selectServiceParameter, action: { [weak self] id in self?.action.send(PaymentsServicesViewModelAction.ItemTapped(itemId: id)) })
                        
                    case .selected(let service):
                        // single service for category
                        model.action.send(ModelAction.Payment.Begin.Request(source: .service(service)))

                    case .failed(let error):
                        print(error.localizedDescription)
                    }
                    
                case let payload as ModelAction.Payment.Begin.Response:
                    switch payload.result {
                    case .success(let operation):
                        break
//                        operationViewModel = PaymentsOperationViewModel(model, operation: operation, dismissAction: { [weak self] in self?.action.send(PaymentsServicesViewModelAction.DissmissOperationView())})
//                        isOperationViewActive = true
                        
                    case .failure(let error):
                        //TODO: log error
                        print(error.localizedDescription)
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

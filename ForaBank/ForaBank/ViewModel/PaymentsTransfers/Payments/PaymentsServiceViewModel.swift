//
//  PaymentsServiceViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.02.2022.
//

import SwiftUI
import Combine

class PaymentsServiceViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var header: HeaderViewModel
    lazy var select: PaymentsSelectServiceView.ViewModel = PaymentsSelectServiceView.ViewModel(with: parameter, action: { [weak self] id in self?.action.send(PaymentsServiceViewModelAction.ItemTapped(itemId: id)) })
    @Published var isOperationViewActive: Bool
    var operationViewModel: PaymentsOperationViewModel?
    
    private let parameter: Payments.ParameterSelectService
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(header: HeaderViewModel,
                  parameter: Payments.ParameterSelectService,
                  isOperationViewActive: Bool = false,
                  model: Model = .emptyMock) {
        
        self.header = header
        self.parameter = parameter
        self.isOperationViewActive = isOperationViewActive
        self.model = model
    }
    
    internal init(_ model: Model, category: Payments.Category, parameter: Payments.ParameterSelectService) {
        
        self.header = HeaderViewModel(title: category.name)
        self.parameter = parameter
        self.isOperationViewActive = false
        self.model = model
        
        bind()
    }
    
    struct HeaderViewModel {
        
        let title: String
    }
    
    func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.Payment.Begin.Response:
                    switch payload {
                    case .success(let operation):
                        operationViewModel = PaymentsOperationViewModel(model, operation: operation)
                        isOperationViewActive = true
                        
                    case .failure(let errorMessage):
                        self.action.send(PaymentsServiceViewModelAction.Alert(message: errorMessage))
                    }

                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsServiceViewModelAction.ItemTapped:
                    guard let selectServiceParameter = select.source as? Payments.ParameterSelectService,
                            let selectedService = selectServiceParameter.options.first(where: { $0.id == payload.itemId})?.service else {
                        return
                    }
                    model.action.send(ModelAction.Payment.Begin.Request(base: .service(selectedService)))
                    
                case _ as PaymentsServiceViewModelAction.DissmissOperationView:
                    isOperationViewActive = false
                    operationViewModel = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Action

enum PaymentsServiceViewModelAction {
    
    struct ItemTapped: Action {
        
        let itemId: PaymentsSelectServiceView.ViewModel.ID
    }
    
    struct DissmissOperationView: Action {}
    
    struct Dismiss: Action {}
    
    enum Spinner {
        
        struct Show: Action {}
        struct Hide: Action {}
    }
    
    struct Alert: Action {
        
        let message: String
    }
}


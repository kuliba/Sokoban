//
//  PaymentsServicesViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.02.2022.
//

import SwiftUI
import Combine

class PaymentsServicesViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var header: HeaderViewModel
    lazy var select: PaymentsSelectServiceView.ViewModel = PaymentsSelectServiceView.ViewModel(with: parameter, action: { [weak self] id in self?.action.send(PaymentsServicesViewModelAction.ItemTapped(itemId: id)) })
    @Published var isOperationViewActive: Bool
    var operationViewModel: PaymentsOperationViewModel?
    
    private let parameter: Payments.ParameterSelectService
    private let rootActions: PaymentsViewModel.RootActions
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(header: HeaderViewModel,
                  parameter: Payments.ParameterSelectService,
                  isOperationViewActive: Bool = false,
                  rootActions: PaymentsViewModel.RootActions,
                  model: Model = .emptyMock) {
        
        self.header = header
        self.parameter = parameter
        self.isOperationViewActive = isOperationViewActive
        self.rootActions = rootActions
        self.model = model
    }
    
    internal init(_ model: Model, category: Payments.Category, parameter: Payments.ParameterSelectService, rootActions: PaymentsViewModel.RootActions) {
        
        self.header = HeaderViewModel(title: category.name, dismissAction: rootActions.dismiss)
        self.parameter = parameter
        self.isOperationViewActive = false
        self.rootActions = rootActions
        self.model = model
        
        bind()
    }
    
    struct HeaderViewModel {
        
        let title: String
        let dismissAction: () -> Void
    }
    
    func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.Payment.Begin.Response:
                    switch payload.result {
                    case .success(let operation):
                        operationViewModel = PaymentsOperationViewModel(model, operation: operation, rootActions: .init(dismiss: { [weak self] in self?.action.send(PaymentsServicesViewModelAction.DissmissOperationView())}, spinner: rootActions.spinner))
                        isOperationViewActive = true
                        
                    case .failure(let error):
                        //TODO: log error
                        print(error.localizedDescription)
                    }

                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsServicesViewModelAction.ItemTapped:
                    guard let selectServiceParameter = select.source as? Payments.ParameterSelectService,
                            let selectedService = selectServiceParameter.options.first(where: { $0.id == payload.itemId})?.service else {
                        return
                    }
                    model.action.send(ModelAction.Payment.Begin.Request(source: .service(selectedService)))
                    
                case _ as PaymentsServicesViewModelAction.DissmissOperationView:
                    isOperationViewActive = false
                    operationViewModel = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

enum PaymentsServicesViewModelAction {
    
    struct ItemTapped: Action {
        
        let itemId: PaymentsSelectServiceView.ViewModel.ID
    }
    
    struct DissmissOperationView: Action {}
}

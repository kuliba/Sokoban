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
    @Published var select: PaymentsParameterSelectServiceView.ViewModel?
    @Published var isOperationViewActive: Bool
    var operationViewModel: PaymentsOperationViewModel?
    
    private let category: Payments.Category
    private var selectedService: Payments.Service?
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(header: HeaderViewModel,
                  select: PaymentsParameterSelectServiceView.ViewModel?,
                  isOperationViewActive: Bool = false,
                  category: Payments.Category,
                  selectedService: Payments.Service? = nil,
                  model: Model = .emptyMock
    ) {
        self.header = header
        self.select = select
        self.isOperationViewActive = isOperationViewActive
        self.category = category
        self.selectedService = selectedService
        self.model = model
    }
    
    internal init(_ model: Model, category: Payments.Category) {
        
        self.header = HeaderViewModel(title: category.name)
        self.select = nil
        self.isOperationViewActive = false
        self.category = category
        self.selectedService = nil
        self.model = model
        
        bind()
        model.action.send(ModelAction.Payment.Services.Request(category: category))
    }
    
    class HeaderViewModel: ObservableObject {
        
        var title: String
        
        internal init(title: String) {
            
            self.title = title
        }
    }
    
    func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.Payment.Services.Response:
                    switch payload {
                    case .select(let selectServiceParameter):
                        // multiple services for category
                        select = PaymentsParameterSelectServiceView.ViewModel(with: selectServiceParameter, action: { [weak self] id in self?.action.send(PaymentsServicesViewModelAction.ItemTapped(itemId: id)) })
                        
                    case .selected(let service):
                        // single service for category
                        model.action.send(ModelAction.Payment.Begin.Request(source: .service(service)))

                    case .failed(let error):
                        print(error.localizedDescription)
                    }
                    
                case let payload as ModelAction.Payment.Begin.Response:
                    switch payload.result {
                    case .success(let operation):
                        do {
                            
                            operationViewModel = try PaymentsOperationViewModel(model, operation: operation, dismissAction: { [weak self] in self?.action.send(PaymentsServicesViewModelAction.DissmissOperationView())})
                            isOperationViewActive = true
                            
                        } catch {
                            //TODO: log error
                            print(error.localizedDescription)
                        }
                        
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
                    guard let selectServiceParameter = select?.parameter as? Payments.ParameterSelectService,
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
        
        let itemId: PaymentsParameterSelectServiceView.ViewModel.ID
    }
    
    struct DissmissOperationView: Action {}
}

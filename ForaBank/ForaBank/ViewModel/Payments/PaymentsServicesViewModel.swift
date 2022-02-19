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
    
    private var bindings = Set<AnyCancellable>()
    private let model: Model
    private let category: Payments.Category
    private var itemsData: [Payments.Parameter.Service]?
    @Published var items: [PaymentsTaxesButtonInfoCellView.ViewModel]
    @Published var header: HeaderViewModel?
    @Published var selectedService: Payments.Service?
    @Published var isPaymentViewActive: Bool
    
    internal init(model: Model,
                  category: Payments.Category,
                  items: [PaymentsTaxesButtonInfoCellView.ViewModel],
                  header: HeaderViewModel?,
                  isPaymentViewActive: Bool,
                  selectedService: Payments.Service? = nil
    ) {
        self.model = model
        self.category = category
        self.items = items
        self.header = header
        self.isPaymentViewActive = isPaymentViewActive
        self.selectedService = selectedService
        bind()
    }
    
    internal init(model: Model, category: Payments.Category, isPaymentViewActive: Bool) {
        self.model = model
        self.items = []
        self.category = category
        self.isPaymentViewActive = isPaymentViewActive
        bind()
        model.action.send(ModelAction.Payment.Services.Request(category: category))
        
    }
    
    var operationViewModel: PaymentsOperationViewModel? {
        guard let selectedService = selectedService else {return nil}
        switch selectedService {
            // В зависимости от типа выбранного сервиса, готовим view model выбранного сервиса
        default: return nil
        }
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
                    // Update items
                    switch payload.result {
                    case .success(let items):
                        self.itemsData = items
                        self.header = HeaderViewModel(title: "Налоги и услуги")
                        self.items = items.map({ parameter in
                            return .init(parameter: parameter) { [weak self] id in
                                self?.action.send(PaymentsServicesViewModelAction.ItemTapped(itemId: id))
                            }
                        })
                    case .failure(_):
                        print()
                    }
                default: break
                }
 
            }.store(in: &bindings)
        
        $selectedService
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] selectedService in
                if selectedService != nil {
                    self.isPaymentViewActive = true
                } else {
                    self.isPaymentViewActive = false
                }
            } .store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsServicesViewModelAction.ItemTapped:
                    guard let itemsData = itemsData,
                          let index = items.firstIndex(where: { $0.id == payload.itemId }),
                          itemsData.count > index
                    else {return}
                    selectedService = itemsData[index].service
                    
                default: break
                }
 
            }.store(in: &bindings)
    }
    
}

enum PaymentsServicesViewModelAction {
    
    struct ItemTapped: Action {
        let itemId: PaymentsTaxesButtonInfoCellView.ViewModel.ID
    }
}

//
//  PaymentsOperationViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.02.2022.
//

import SwiftUI
import Combine

class PaymentsOperationViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()

    @Published var header: HeaderViewModel
    @Published var items: [PaymentsParameterViewModel]
    @Published var amount: PaymentsParameterAmountView.ViewModel?

    var operation: Payments.Operation
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(header: HeaderViewModel,
                  items: [PaymentsParameterViewModel],
                  amount: PaymentsParameterAmountView.ViewModel?,
                  operation: Payments.Operation = .emptyMock,
                  model: Model = .emptyMock) {
        
        self.header = header
        self.items = items
        self.amount = amount
        self.operation = operation
        self.model = model
    }
    
    internal init(_ model: Model, operation: Payments.Operation, dismissAction: @escaping () -> Void) throws {
        
        self.model = model
        self.header = .init(title: operation.service.name, action: dismissAction)
        self.items = try Self.items(parameters: operation.parameters)
        self.operation = operation
        
        bind()
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                default: break
                }
 
            }.store(in: &bindings)
    }
    
    static func items(parameters: [Payments.Parameter]) throws -> [PaymentsParameterViewModel] {
    
        var result = [PaymentsParameterViewModel]()
        for parameter in parameters {
            
            switch parameter {
            case let parameterSelect as Payments.ParameterSelect:
                result.append(try PaymentsParameterSelectView.ViewModel(with: parameterSelect))
                
            case let parameterSwitch as Payments.ParameterSelectSwitch:
                result.append(try PaymentsParameterSwitchView.ViewModel(with: parameterSwitch))
                
            case let parameterInfo as Payments.ParameterInfo:
                result.append(try PaymentsParameterInfoView.ViewModel(with: parameterInfo))
                
            default:
                continue
            }
        }
        
        return result
    }
}

extension PaymentsOperationViewModel {
    
    struct HeaderViewModel {
        
        let title: String
        let backButtonIcon = Image("back_button")
        let action: () -> Void
    }
}

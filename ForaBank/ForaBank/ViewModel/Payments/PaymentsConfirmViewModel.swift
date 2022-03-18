//
//  PaymentsConfirmViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 10.03.2022.
//

import Foundation
import SwiftUI
import Combine

class PaymentsConfirmViewModel: PaymentsOperationViewModel {
    
    override init(_ model: Model, operation: Payments.Operation, rootActions: PaymentsViewModel.RootActions) {
        
        print("Payments: init confirm")
        
        super.init(model, operation: operation, rootActions: rootActions)
        
    }
    
    override func createFooter(from parameters: [ParameterRepresentable]) -> PaymentsOperationViewModel.FooterViewModel? {
        
        return .button(.init(title: "Оплатить", isEnabled: false, action: { [weak self] in
            self?.action.send(PaymentsOperationViewModelAction.Confirm())
        }))
    }
    
    override func bind() {
        
        bindAction()
        bindItems()
        
        print("Payments: bind confirm")
    }
    
    override func bindAction() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsOperationViewModelAction.Confirm:
                    let results = items.value.map{ ($0.result, $0.source.affectsHistory) }
                    let update = operation.update(with: results)
                    model.action.send(ModelAction.Payment.Complete.Request(operation: update.operation))
     
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

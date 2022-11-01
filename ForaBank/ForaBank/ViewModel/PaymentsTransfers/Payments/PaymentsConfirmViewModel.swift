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
    
    /*
    override init(_ model: Model, operation: Payments.Operation) {
        
        super.init(model, operation: operation)
        
    }
    */
    /*
    override func createFooter(from parameters: [PaymentsParameterRepresentable]) -> PaymentsOperationViewModel.FooterViewModel? {
        
        return .button(.init(title: "Оплатить", isEnabled: false, action: { [weak self] in
            self?.action.send(PaymentsOperationViewModelAction.Confirm())
        }))
    }
     */
        
    override func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Auth.VerificationCode.PushRecieved:
                    /*
                    guard let codeParameter = items.value.first(where: { $0.id == Payments.Parameter.Identifier.code.rawValue }) as? PaymentsInputView.ViewModel else {
                        return
                    }
                    
                    codeParameter.content = payload.code
                     */
                    break

                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
//                case _ as PaymentsOperationViewModelAction.Confirm:
                    //FIXME: refactor
//                    break
                    /*
                    let results = itemsAll.map{ ($0.result, $0.source.affectsHistory) }
                    let update = operation.update(with: results)
                    model.action.send(ModelAction.Payment.Complete.Request(operation: update.operation))
                    rootActions.spinner.show()
                     */
     
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//
//  PaymentsServicesLatestPaymentsSectionViewModel.swift
//  Vortex
//
//  Created by Andryusina Nataly on 24.03.2023.
//

import Foundation
import SwiftUI
import Combine

class PaymentsServicesLatestPaymentsSectionViewModel: PaymentsServicesSectionViewModel, ObservableObject {
    
    override var type: PaymentsServicesSectionViewModel.Kind { .latestPayments }
    
    let latestPayments: LatestPaymentsView.ViewModel
    
    init(latestPayments: LatestPaymentsView.ViewModel, mode: Mode, model: Model) {
        
        self.latestPayments = latestPayments
        super.init(model: model, mode: mode)
    }
    
    convenience init(model: Model, including: Set<LatestPaymentData.Kind>) {
        
        let latestPaymentsViewModel = LatestPaymentsView.ViewModel(model, mode: .extended, isBaseButtons: false, filter: .including(including))
        self.init(latestPayments: latestPaymentsViewModel, mode: .select, model: model)
        
        bind()
    }
    
    func bind() {
        
        latestPayments.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as LatestPaymentsViewModelAction.ButtonTapped.LatestPayment:
                    if let latestPayment = payload.latestPayment as? PaymentServiceData {
                        self.action.send(PaymentsServicesSectionViewModelAction.LatestPayments.ItemDidTapped(latestPayment: latestPayment))
                    }
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Action

extension PaymentsServicesSectionViewModelAction {
    
    enum LatestPayments {
        
        struct ItemDidTapped: Action {
            
            let latestPayment: PaymentServiceData
        }
    }
}

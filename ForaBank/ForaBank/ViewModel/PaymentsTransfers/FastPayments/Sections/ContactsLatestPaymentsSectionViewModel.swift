//
//  ContactsLatestPaymentsSectionViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 14.11.2022.
//

import Foundation
import SwiftUI
import Combine

class ContactsLatestPaymentsSectionViewModel: ContactsSectionViewModel, ObservableObject {
    
    override var type: ContactsSectionViewModel.Kind { .latestPayments }
    
    let latestPayments: LatestPaymentsView.ViewModel
    
    init(latestPayments: LatestPaymentsView.ViewModel, mode: Mode, model: Model) {
        
        self.latestPayments = latestPayments
        super.init(model: model, mode: mode)
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "init")
    }
    
    convenience init(model: Model, including: Set<LatestPaymentData.Kind>) {
        
        let latestPaymentsViewModel = LatestPaymentsView.ViewModel(model, isBaseButtons: false, filter: .including(including))
        self.init(latestPayments: latestPaymentsViewModel, mode: .fastPayment, model: model)
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
    
    func bind() {
        
        latestPayments.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as LatestPaymentsViewModelAction.ButtonTapped.LatestPayment:
                    self.action.send(ContactsSectionViewModelAction.LatestPayments.ItemDidTapped(latestPayment: payload.latestPayment))
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
    }
}

//MARK: - Action

extension ContactsSectionViewModelAction {
    
    enum LatestPayments {
        
        struct ItemDidTapped: Action {
            
            let latestPayment: LatestPaymentData
        }
    }
}

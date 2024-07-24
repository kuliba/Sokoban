//
//  UtilityServicePaymentFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import Combine

struct UtilityServicePaymentFlowState<ViewModel> {
    
    let viewModel: ViewModel
    private let subscription: AnyCancellable
    var alert: Alert?
    var fullScreenCover: FullScreenCover?
    var modal: Modal?
    
    init(
        viewModel: ViewModel,
        subscription: AnyCancellable,
        alert: Alert? = nil,
        fullScreenCover: FullScreenCover? = nil,
        modal: Modal? = nil
    ) {
        self.viewModel = viewModel
        self.subscription = subscription
        self.alert = alert
        self.fullScreenCover = fullScreenCover
        self.modal = modal
    }
}

extension UtilityServicePaymentFlowState {
    
    enum Alert {
        
        case paymentRestartConfirmation
        case serverError(String)
        case terminalError(String)
    }
    
    enum FullScreenCover {
        
        case completed(TransactionResult)
        
        typealias TransactionResult = Result<AnywayTransactionReport, Fraud>
        
        struct Fraud: Equatable, Error {
            
            let formattedAmount: String
            let hasExpired: Bool
        }
    }
    
    enum Modal {
        
        case fraud(FraudNoticePayload)
    }
}

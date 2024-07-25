//
//  UtilityServicePaymentFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import Combine

struct UtilityServicePaymentFlowState {
    
    let content: Content
    private let subscription: AnyCancellable
    var alert: Alert?
    var fullScreenCover: FullScreenCover?
    var modal: Modal?
    
    init(
        content: Content,
        subscription: AnyCancellable,
        alert: Alert? = nil,
        fullScreenCover: FullScreenCover? = nil,
        modal: Modal? = nil
    ) {
        self.content = content
        self.subscription = subscription
        self.alert = alert
        self.fullScreenCover = fullScreenCover
        self.modal = modal
    }
}

extension UtilityServicePaymentFlowState {
    
    typealias Content = AnywayTransactionViewModel
    
    enum Alert: Equatable {
        
        case paymentRestartConfirmation
        case serverError(String)
        case terminalError(String)
    }
    
    enum FullScreenCover: Equatable {
        
        case completed(TransactionResult)
        
        typealias TransactionResult = Result<AnywayTransactionReport, Fraud>
        
        struct Fraud: Equatable, Error {
            
            let formattedAmount: String
            let hasExpired: Bool
        }
    }
    
    enum Modal: Equatable {
        
        case fraud(FraudNoticePayload)
    }
}

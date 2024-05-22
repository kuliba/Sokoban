//
//  ObservingPaymentFlowMockViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import RxViewModel

typealias ObservingPaymentFlowMockViewModel = RxObservingViewModel<PaymentFlowMockState, PaymentFlowMockEvent, Never>

struct PaymentFlowMockState: Equatable {
    
    var isComplete: Bool = false
    var fraud: Fraud?
    var errorMessage: String?
}

enum PaymentFlowMockEvent: Equatable {
    
    case completePayment
    case detectFraud
    case produceError
}

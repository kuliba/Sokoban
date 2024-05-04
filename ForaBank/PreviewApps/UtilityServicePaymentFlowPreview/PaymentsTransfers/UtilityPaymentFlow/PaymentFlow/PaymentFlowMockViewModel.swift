//
//  PaymentFlowMockViewModel.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

import Combine

final class PaymentFlowMockViewModel: ObservableObject {
    
    @Published private(set) var state: Fraud?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        state: Fraud? = nil,
        notify: @escaping FraudNotify
    ) {
        self.state = state

        $state
            .compactMap { $0 }
            .sink(receiveValue: notify)
            .store(in: &cancellables)
    }
    
    func detectFraud() {
        
        self.state = .init()
    }
}

extension PaymentFlowMockViewModel {
    
    typealias Fraud = PaymentFlowState.Modal.Fraud
    typealias FraudNotify = (Fraud) -> Void
}

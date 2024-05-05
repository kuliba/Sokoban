//
//  ObservingPaymentFlowMockViewModel.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

import Combine

final class ObservingPaymentFlowMockViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        state: State = .init(),
        notify: @escaping Notify
    ) {
        self.state = state
        
        $state
            .compactMap(\.errorMessage)
            .map(Projection.errorMessage)
            .sink(receiveValue: notify)
            .store(in: &cancellables)
        
        $state
            .compactMap(\.fraud)
            .map(Projection.fraud)
            .sink(receiveValue: notify)
            .store(in: &cancellables)
    }
    
    func detectFraud() {
        
        state.fraud = .init()
    }
    
    func produceError() {
        
        state.errorMessage = "Payment error occurred."
    }
}

extension ObservingPaymentFlowMockViewModel {
    
    typealias State = PaymentFlowMockState
    typealias Projection = PaymentsTransfersViewModelFactory.PaymentStateProjection
    typealias Notify = (Projection) -> Void
}

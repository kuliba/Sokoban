//
//  ClosePaymentsViewModelWrapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.09.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class ClosePaymentsViewModelWrapper: ObservableObject {
    
    @Published private(set) var isClosed = false
    
    let paymentsViewModel: PaymentsViewModel
    
    init(
        model: Model,
        service: Payments.Service,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        let closeSubject = PassthroughSubject<Void, Never>()
        
        self.paymentsViewModel = .init(
            model,
            service: service,
            closeAction: { closeSubject.send(()) }
        )
        
        closeSubject
            .map { _ in true }
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$isClosed)
    }
}

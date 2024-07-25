//
//  ServicePaymentBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class ServicePaymentBinder {
    
    let content: Content
    let flow: Flow
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        content: Content,
        flow: Flow,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.content = content
        self.flow = flow
        self.bind(on: scheduler)
    }
    
    typealias Content = AnywayTransactionViewModel
    typealias Flow = ServicePaymentFlowModel
}

extension ServicePaymentBinder {
    
    func bind(on scheduler: AnySchedulerOf<DispatchQueue>) {
        
        content.$state
            .map(\.transaction.projection)
            .removeDuplicates()
            .debounce(for: 0.1, scheduler: scheduler)
            .receive(on: scheduler)
            .sink { [weak self] in self?.flow.event(.notify($0)) }
            .store(in: &cancellables)
    }
}

private extension AnywayTransactionState.Transaction {
    
    var projection: ServicePaymentFlowEvent.TransactionProjection {
        
        return .init(context: context, status: status)
    }
}

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
    
    private let cancellable: AnyCancellable
    
    init(
        content: Content,
        flow: Flow,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.content = content
        self.flow = flow
        self.cancellable = content.$state
            .map(\.transaction.projection)
            .removeDuplicates()
            .debounce(for: 0.1, scheduler: scheduler)
            .receive(on: scheduler)
            .sink { [weak flow] in flow?.event(.notify($0)) }
    }
    
    typealias Content = AnywayTransactionViewModel
    typealias Flow = ServicePaymentFlowModel
}

private extension AnywayTransactionState.Transaction {
    
    var projection: ServicePaymentFlowEvent.TransactionProjection {
        
        return .init(context: context, status: status)
    }
}

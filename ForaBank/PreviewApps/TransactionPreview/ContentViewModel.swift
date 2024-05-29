//
//  ContentViewModel.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import Foundation

final class ContentViewModel: ObservableObject {
    
    @Published private(set) var flow: Flow
    
    private let factory: Factory
    
    init(
        flow: Flow,
        factory: Factory
    ) {
        self.flow = flow
        self.factory = factory
    }
    
    func dismissDestination() {
        
        flow.destination = nil
    }
    
    func openPayment() {
        
        let initialState = AnywayTransactionState.preview
        
        let transactionViewModel = factory.makeTransactionViewModel(
            initialState,
            { [weak self] in self?.observe($0) }
        )
        
        flow.destination = .payment(transactionViewModel)
    }
    
    private func observe(
        _ state: AnywayTransactionState
    ) {
        guard let status = state.status else { return }
        
        switch status {
        case .fraudSuspected:
            flow.modal = .fraud
            
        default:
#warning("FIXME")
            fatalError("unimplemented")
        }
    }
    
    func hideEventList() {
        
        flow.modal = nil
    }
    
    func showEventList() {
        
        flow.modal = .eventList
    }
}

extension ContentViewModel {
    
    typealias Factory = ContentViewModelFactory
}

extension ContentViewModel {
    
    static func `default`() -> Self {
        
        .init(flow: .init(), factory: .default())
    }
}

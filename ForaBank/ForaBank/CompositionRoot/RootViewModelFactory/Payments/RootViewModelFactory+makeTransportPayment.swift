//
//  RootViewModelFactory+makeTransportPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeTransportPayment() -> TransportPaymentsViewModel? {
        
        model.makeTransportPaymentsViewModel(type: .transport)
    }
}

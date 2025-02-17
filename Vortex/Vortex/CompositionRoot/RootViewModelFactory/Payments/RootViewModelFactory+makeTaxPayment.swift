//
//  RootViewModelFactory+makeTaxPayment.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeTaxPayment() -> ClosePaymentsViewModelWrapper {
        
        return .init(
            model: model,
            category: .taxes,
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func makeTaxPayment(
        c2gFlag: C2GFlag,
        closeAction: @escaping () -> Void
    ) -> CategoryPickerSectionDomain.Destination.Tax {
        
        switch c2gFlag.rawValue {
        case .active:
            return .v1(.init())
            
        case .inactive:
            return .legacy(.init(
                category: .taxes,
                model: model,
                closeAction: closeAction
            ))
        }
    }
    
    @inlinable
    func makeTaxPayment(
        closeAction: @escaping () -> Void
    ) -> PaymentsViewModel {
        
        return .init(
            category: .taxes, 
            model: model,
            closeAction: closeAction
        )
    }
}

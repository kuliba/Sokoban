//
//  RootViewModelFactory+makeCorporateTransfers.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeCorporateTransfers(
    ) -> PaymentsTransfersCorporateTransfers {
        
        return .init(meToMe: makeMeToMeFlow())
    }
}

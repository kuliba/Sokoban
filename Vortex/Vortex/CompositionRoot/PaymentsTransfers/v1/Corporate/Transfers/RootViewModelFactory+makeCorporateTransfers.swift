//
//  RootViewModelFactory+makeCorporateTransfers.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeCorporateTransfers(
        featureFlags: FeatureFlags
    ) -> PaymentsTransfersCorporateTransfers {
        
        return .init(
            meToMe: makeMeToMeFlow(),
            openProduct: makeOpenProductFlow(featureFlags: featureFlags)
        )
    }
}

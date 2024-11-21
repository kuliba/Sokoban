//
//  RootComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

protocol RootComposer {
    
    func makeBinder(
        featureFlags: FeatureFlags,
        dismiss: @escaping () -> Void
    ) -> RootViewDomain.Binder
}

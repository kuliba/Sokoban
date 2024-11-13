//
//  RootFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Combine

protocol RootFactory {
    
    func makeBinder(
        featureFlags: FeatureFlags,
        dismiss: @escaping () -> Void
    ) -> RootViewDomain.Binder
    
    func makeRootViewFactory(
        featureFlags: FeatureFlags
    ) -> RootViewFactory
}

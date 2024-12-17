//
//  RootViewComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.11.2024.
//

protocol RootViewComposer {
    
    func makeRootViewFactory(
        featureFlags: FeatureFlags
    ) -> RootViewFactory
}

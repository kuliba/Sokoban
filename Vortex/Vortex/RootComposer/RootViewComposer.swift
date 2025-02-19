//
//  RootViewComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.11.2024.
//

protocol RootViewComposer {
    
    func makeRootViewFactory(
        featureFlags: FeatureFlags,
        rootEvent: @escaping (RootViewSelect) -> Void
    ) -> RootViewFactory
}

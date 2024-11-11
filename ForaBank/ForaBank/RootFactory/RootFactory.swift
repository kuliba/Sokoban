//
//  RootFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Combine

protocol RootFactory {
    
    func makeRootViewModel(
        _: FeatureFlags,
        bindings: inout Set<AnyCancellable>
    ) -> RootViewModel
    
    func makeGetRootNavigation(
        _: FeatureFlags
    ) -> RootViewDomain.GetNavigation
    
    func makeRootViewFactory(
        _: FeatureFlags
    ) -> RootViewFactory
}

//
//  RootFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

protocol RootFactory {
    
    func makeRootViewModel(_: FeatureFlags) -> RootViewModel
    func makeRootViewFactory(_: FeatureFlags) -> RootViewFactory
}

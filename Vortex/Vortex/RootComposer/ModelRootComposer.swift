//
//  ModelRootComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Combine
import Foundation
import PayHubUI

final class ModelRootComposer {
    
    private let rootViewModelFactory: RootViewModelFactory
    private let makeRootViewFactoryComposer: MakeRootViewFactoryComposer
    
    init(
        rootViewModelFactory: RootViewModelFactory,
        makeRootViewFactoryComposer: @escaping MakeRootViewFactoryComposer
    ) {
        self.rootViewModelFactory = rootViewModelFactory
        self.makeRootViewFactoryComposer = makeRootViewFactoryComposer
    }
    
    typealias MakeRootViewFactoryComposer = (FeatureFlags) -> RootViewFactoryComposer
}

extension ModelRootComposer: RootComposer {
    
    func makeBinder(
        featureFlags: FeatureFlags,
        dismiss: @escaping () -> Void
    ) -> RootViewDomain.Binder {
        
        return rootViewModelFactory.make(
            dismiss: dismiss,
            collateralLoanLandingFlag: featureFlags.collateralLoanLandingFlag,
            paymentsTransfersFlag: featureFlags.paymentsTransfersFlag,
            savingsAccountFlag: featureFlags.savingsAccountFlag
        )
    }
}

extension ModelRootComposer: RootViewComposer {

    func makeRootViewFactory(
        featureFlags: FeatureFlags
    ) -> RootViewFactory {
        
        let composer = makeRootViewFactoryComposer(featureFlags)
        
        return composer.compose()
    }
}

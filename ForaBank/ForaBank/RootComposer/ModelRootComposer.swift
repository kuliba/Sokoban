//
//  ModelRootComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Combine
import Foundation
import PayHubUI

final class ModelRootComposer {
    
    private let httpClient: HTTPClient
    private let logger: LoggerAgentProtocol
    private let model: Model
    private let resolveQR: RootViewModelFactory.ResolveQR
    private let schedulers: Schedulers
    private let makeRootViewFactoryComposer: MakeRootViewFactoryComposer
    
    init(
        httpClientFactory: HTTPClientFactory,
        logger: LoggerAgentProtocol,
        model: Model,
        resolveQR: @escaping RootViewModelFactory.ResolveQR,
        schedulers: Schedulers = .init(),
        makeRootViewFactoryComposer: @escaping MakeRootViewFactoryComposer
    ) {
        self.httpClient = httpClientFactory.makeHTTPClient()
        self.logger = logger
        self.model = model
        self.resolveQR = resolveQR
        self.schedulers = schedulers
        self.makeRootViewFactoryComposer = makeRootViewFactoryComposer
    }
    
    typealias MakeRootViewFactoryComposer = (FeatureFlags) -> RootViewFactoryComposer
}

extension ModelRootComposer: RootComposer {
    
    func makeBinder(
        featureFlags: FeatureFlags,
        dismiss: @escaping () -> Void
    ) -> RootViewDomain.Binder {
        
        let factory = RootViewModelFactory(
            model: model,
            httpClient: httpClient,
            logger: logger, 
            resolveQR: resolveQR,
            schedulers: schedulers
        )
        
        return factory.make(
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

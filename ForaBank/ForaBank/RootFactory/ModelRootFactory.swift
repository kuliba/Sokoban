//
//  ModelRootFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Combine
import Foundation
import PayHubUI

final class ModelRootFactory {
    
    private let httpClient: HTTPClient
    private let logger: LoggerAgentProtocol
    private let model: Model
    private let schedulers: Schedulers

    init(
        httpClientFactory: HTTPClientFactory,
        logger: LoggerAgentProtocol,
        model: Model,
        schedulers: Schedulers = .init()
    ) {
        self.httpClient = httpClientFactory.makeHTTPClient()
        self.logger = logger
        self.model = model
        self.schedulers = schedulers
    }
}

extension ModelRootFactory: RootFactory {
    
    func makeBinder(
        featureFlags: FeatureFlags,
        dismiss: @escaping () -> Void
    ) -> RootViewDomain.Binder {
        
        let factory = RootViewModelFactory(
            model: model,
            httpClient: httpClient,
            logger: logger,
            schedulers: schedulers
        )
        
        return factory.make(
            dismiss: dismiss,
            qrResolverFeatureFlag: .active,
            fastPaymentsSettingsFlag: .live,
            utilitiesPaymentsFlag: .live,
            historyFilterFlag: true,
            changeSVCardLimitsFlag: .active,
            collateralLoanLandingFlag: featureFlags.collateralLoanLandingFlag,
            getProductListByTypeV6Flag: .active,
            marketplaceFlag: .active,
            paymentsTransfersFlag: featureFlags.paymentsTransfersFlag,
            updateInfoStatusFlag: .active,
            savingsAccountFlag: featureFlags.savingsAccountFlag
        )
    }
    
    func makeRootViewFactory(
        featureFlags: FeatureFlags
    ) -> RootViewFactory {
        
        let composer = RootViewFactoryComposer(
            model: model,
            httpClient: httpClient,
            historyFeatureFlag: true,
            marketFeatureFlag: .active,
            savingsAccountFlag: featureFlags.savingsAccountFlag
        )
        
        return composer.compose()
    }
}

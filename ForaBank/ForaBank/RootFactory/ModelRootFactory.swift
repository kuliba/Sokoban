//
//  ModelRootFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Combine
import Foundation

final class ModelRootFactory {
    
    private let httpClient: HTTPClient
    private let logger: LoggerAgentProtocol
    private let model: Model
    
    init(
        httpClientFactory: HTTPClientFactory,
        logger: LoggerAgentProtocol,
        model: Model
    ) {
        self.httpClient = httpClientFactory.makeHTTPClient()
        self.logger = logger
        self.model = model
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
            logger: logger
        )
        
        return factory.make(
            dismiss: dismiss,
            qrResolverFeatureFlag: .init(.active),
            fastPaymentsSettingsFlag: .init(.active(.live)),
            utilitiesPaymentsFlag: .init(.active(.live)),
            historyFilterFlag: true,
            changeSVCardLimitsFlag: .init(.active),
            getProductListByTypeV6Flag: .init(.active),
            marketplaceFlag: .init(.active),
            paymentsTransfersFlag: featureFlags.paymentsTransfersFlag,
            updateInfoStatusFlag: .init(.active),
            savingsAccountFlag: featureFlags.savingsAccountFlag
        )
    }
    
    func makeRootViewFactory(
        featureFlags: FeatureFlags
    ) -> RootViewFactory {
        
        let composer = RootViewFactoryComposer(
            model: model,
            httpClient: httpClient,
            historyFeatureFlag: featureFlags.historyFilterFlag,
            marketFeatureFlag: featureFlags.marketplaceFlag,
            savingsAccountFlag: featureFlags.savingsAccountFlag
        )
        
        return composer.compose()
    }
}

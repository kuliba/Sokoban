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
        logger: LoggerAgentProtocol,
        model: Model
    ) {
        self.httpClient = HTTPClientFactory.makeHTTPClient(
            with: model,
            logger: logger
        )
        self.logger = logger
        self.model = model
    }
}

extension ModelRootFactory: RootFactory {
    
    func makeRootViewModel(
        _ featureFlags: FeatureFlags,
        bindings: inout Set<AnyCancellable>
    ) -> RootViewModel {
        
        let factory = RootViewModelFactory(
            model: model,
            httpClient: httpClient,
            logger: logger
        )
        
        let rootViewModel = factory.make(
            bindings: &bindings,
            qrResolverFeatureFlag: .init(.active),
            fastPaymentsSettingsFlag: .init(.active(.live)),
            utilitiesPaymentsFlag: featureFlags.utilitiesPaymentsFlag,
            historyFilterFlag: featureFlags.historyFilterFlag,
            changeSVCardLimitsFlag: .init(.active),
            getProductListByTypeV6Flag: .init(.active),
            marketplaceFlag: featureFlags.marketplaceFlag,
            paymentsTransfersFlag: featureFlags.paymentsTransfersFlag,
            updateInfoStatusFlag: .init(.active)
        )
        
        let binder = MarketShowcaseToRootViewModelBinder(
            marketShowcase: rootViewModel.tabsViewModel.marketShowcaseBinder,
            rootViewModel: rootViewModel,
            scheduler: .main
        )

        bindings.formUnion(binder.bind())

        return rootViewModel
    }
    
    func makeRootViewFactory(
        _ featureFlags: FeatureFlags
    ) -> RootViewFactory {
        
        let composer = RootViewFactoryComposer(
            model: model,
            httpClient: httpClient,
            historyFeatureFlag: featureFlags.historyFilterFlag,
            marketFeatureFlag: featureFlags.marketplaceFlag
        )
        
        return composer.compose()
    }
}

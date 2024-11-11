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
            utilitiesPaymentsFlag: .init(.active(.live)),
            historyFilterFlag: true,
            changeSVCardLimitsFlag: .init(.active),
            getProductListByTypeV6Flag: .init(.active),
            marketplaceFlag: .init(.active),
            paymentsTransfersFlag: featureFlags.paymentsTransfersFlag,
            updateInfoStatusFlag: .init(.active),
            savingsAccountFlag: featureFlags.savingsAccountFlag,
            collateralLoanLandingFlag: featureFlags.collateralLoanLandingFlag
        )
        
        let binder = MarketShowcaseToRootViewModelBinder(
            marketShowcase: rootViewModel.tabsViewModel.marketShowcaseBinder,
            rootViewModel: rootViewModel,
            scheduler: .main
        )

        bindings.formUnion(binder.bind())

        return rootViewModel
    }
    
    func makeGetRootNavigation(
        _ featureFlags: FeatureFlags
    ) -> RootViewDomain.GetNavigation {
        
        return { select, notify, completion in
        
            switch select {
            case .scanQR:
                completion(.scanQR)
            }
        }
    }
    
    func makeRootViewFactory(
        _ featureFlags: FeatureFlags
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

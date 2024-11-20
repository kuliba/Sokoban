//
//  ModelRootComposer+ext.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank
import PayHubUI

extension ModelRootComposer {
    
    convenience init(
        httpClientFactory: any HTTPClientFactory = HTTPClientFactorySpy(),
        logger: any LoggerAgentProtocol = LoggerSpy(),
        model: Model = .mockWithEmptyExcept(),
        resolveQR: @escaping RootViewModelFactory.ResolveQR = { _ in .unknown },
        settings: RootViewModelFactorySettings = .iFora,
        schedulers: Schedulers
    ) {
        self.init(
            httpClientFactory: httpClientFactory,
            logger: logger,
            model: model,
            resolveQR: resolveQR,
            schedulers: schedulers,
            rootViewModelFactory: .init(
                model: model,
                httpClient: httpClientFactory.makeHTTPClient(),
                logger: logger,
                resolveQR: resolveQR,
                settings: settings,
                schedulers: schedulers
            ),
            makeRootViewFactoryComposer: { featureFlags in
                
                return .init(
                    model: model,
                    httpClient: httpClientFactory.makeHTTPClient(),
                    historyFeatureFlag: true,
                    marketFeatureFlag: .active,
                    savingsAccountFlag: featureFlags.savingsAccountFlag,
                    schedulers: schedulers
                )
            }
        )
    }
}

//
//  ModelRootComposer+shared.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2024.
//

import PayHubUI

extension ModelRootComposer {
    
    static var shared: ModelRootComposer {
        
        let model: Model = .shared
        let httpClientFactory = ModelHTTPClientFactory(
            logger: LoggerAgent.shared,
            model: model
        )
        let httpClient = httpClientFactory.makeHTTPClient()
        let resolver = QRResolver(isSberQR: model.isSberQR)
        let schedulers = Schedulers()
        
        return .init(
            httpClientFactory: httpClientFactory,
            logger: LoggerAgent.shared,
            model: model,
            resolveQR: resolver.resolve,
            schedulers: schedulers,
            makeRootViewFactoryComposer: { featureFlags in
                
                return .init(
                    model: model,
                    httpClient: httpClient,
                    historyFeatureFlag: true,
                    marketFeatureFlag: .active,
                    savingsAccountFlag: featureFlags.savingsAccountFlag,
                    schedulers: schedulers
                )
            }
        )
    }
}

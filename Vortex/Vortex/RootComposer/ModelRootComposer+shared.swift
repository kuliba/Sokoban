//
//  ModelRootComposer+shared.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.10.2024.
//

import Combine
import PayHubUI

extension ModelRootComposer {
    
    static var shared: ModelRootComposer {
        
        let model: Model = .shared
        let logger: LoggerAgent = .shared
        let httpClientFactory = ModelHTTPClientFactory(
            logger: LoggerAgent.shared,
            model: model
        )
        let httpClient = httpClientFactory.makeHTTPClient()
        let resolver = QRResolver(isSberQR: model.isSberQR)
        let composer = QRScanResultMapperComposer(model: model)
        let mapper = composer.compose()
        let schedulers = Schedulers()
        
        return .init(
            rootViewModelFactory: .init(
                model: model,
                httpClient: httpClient,
                logger: logger,
                mapScanResult: mapper.mapScanResult,
                resolveQR: resolver.resolve,
                scanner: QRScannerView.ViewModel(),
                settings: .prod,
                schedulers: schedulers
            ),
            makeRootViewFactoryComposer: { featureFlags in
                
                return .init(
                    model: model,
                    httpClient: httpClient,
                    historyFeatureFlag: true,
                    savingsAccountFlag: featureFlags.savingsAccountFlag,
                    schedulers: schedulers
                )
            }
        )
    }
}

extension QRScannerView.ViewModel: QRScannerViewModel {
    
    var qrScannerViewActionPublisher: AnyPublisher<QRScannerViewAction, Never> {
        
        action.eraseToAnyPublisher()
    }
}

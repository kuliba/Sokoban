//
//  ModelRootComposer+shared.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.10.2024.
//

import Combine

extension ModelRootComposer {
    
    static var shared: ModelRootComposer {
        
        let model: Model = .shared
        let logger: LoggerAgent = .shared
        let httpClientFactory = ModelHTTPClientFactory(
            logger: LoggerAgent.shared,
            model: model
        )
        let httpClient = httpClientFactory.makeHTTPClient()
        let makeQRResolve = {
            
            let resolver = QRResolver(dependencies: $0)
            return resolver.resolve(string:)
        }
        let composer = QRScanResultMapperComposer(model: model)
        let mapper = composer.compose()
        let schedulers = Schedulers()
        
        return .init(
            rootViewModelFactory: .init(
                model: model,
                httpClient: httpClient,
                logger: logger,
                mapScanResult: mapper.mapScanResult,
                makeQRResolve: makeQRResolve,
                scanner: QRScannerView.ViewModel(),
                settings: .prod,
                schedulers: schedulers
            ),
            makeRootViewFactoryComposer: { featureFlags in
                
                return .init(
                    model: model,
                    httpClient: httpClient,
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

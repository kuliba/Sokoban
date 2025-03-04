//
//  ModelRootComposer+ext.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import Vortex
import PayHub

extension ModelRootComposer {
    
    convenience init(
        httpClient: any HTTPClient = HTTPClientSpy(),
        logger: any LoggerAgentProtocol = LoggerSpy(),
        mapScanResult: @escaping RootViewModelFactory.MapScanResult = { _, completion in completion(.unknown) },
        makeQRResolve: @escaping RootViewModelFactory.MakeResolveQR = { _ in { _ in .unknown }},
        model: Model = .mockWithEmptyExcept(),
        scanner: any QRScannerViewModel = QRScannerViewModelSpy(),
        settings: RootViewModelFactorySettings = .prod,
        schedulers: Schedulers
    ) {
        self.init(
            rootViewModelFactory: .init(
                model: model,
                httpClient: httpClient,
                logger: logger,
                mapScanResult: mapScanResult,
                makeQRResolve: makeQRResolve,
                scanner: scanner,
                settings: settings,
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

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
        httpClient: any HTTPClient = HTTPClientSpy(),
        logger: any LoggerAgentProtocol = LoggerSpy(),
        mapScanResult: @escaping RootViewModelFactory.MapScanResult = { _, completion in completion(.unknown) },
        model: Model = .mockWithEmptyExcept(),
        resolveQR: @escaping RootViewModelFactory.ResolveQR = { _ in .unknown },
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
                resolveQR: resolveQR,
                scanner: scanner,
                settings: settings,
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

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
        model: Model = .mockWithEmptyExcept(),
        resolveQR: @escaping RootViewModelFactory.ResolveQR = { _ in .unknown },
        scanner: any QRScannerViewModel = QRScannerViewModelSpy(),
        settings: RootViewModelFactorySettings = .iFora,
        schedulers: Schedulers
    ) {
        self.init(
            rootViewModelFactory: .init(
                model: model,
                httpClient: httpClient,
                logger: logger,
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
                    marketFeatureFlag: .active,
                    savingsAccountFlag: featureFlags.savingsAccountFlag,
                    schedulers: schedulers
                )
            }
        )
    }
}

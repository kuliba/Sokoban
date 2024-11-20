//
//  ModelRootFactory+ext.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank
import PayHubUI

extension ModelRootFactory {
    
    static func immediate(
        httpClientFactory: any HTTPClientFactory = HTTPClientFactorySpy(),
        logger: any LoggerAgentProtocol = LoggerSpy(),
        model: Model = .mockWithEmptyExcept(),
        resolveQR: @escaping RootViewModelFactory.ResolveQR = { _ in .unknown }
    ) -> ModelRootFactory {
        
        return .init(
            httpClientFactory: httpClientFactory,
            logger: logger,
            model: model,
            resolveQR: resolveQR,
            schedulers: .immediate
        )
    }
    
    static func test(
        httpClientFactory: any HTTPClientFactory = HTTPClientFactorySpy(),
        logger: any LoggerAgentProtocol = LoggerSpy(),
        model: Model = .mockWithEmptyExcept(),
        resolveQR: @escaping RootViewModelFactory.ResolveQR = { _ in .unknown },
        schedulers: Schedulers
    ) -> ModelRootFactory {
        
        return .init(
            httpClientFactory: httpClientFactory, 
            logger: logger,
            model: model,
            resolveQR: resolveQR,
            schedulers: schedulers
        )
    }
}

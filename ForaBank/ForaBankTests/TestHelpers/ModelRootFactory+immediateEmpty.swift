//
//  ModelRootFactory+immediateEmpty.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank
import PayHubUI

extension ModelRootFactory {
    
    static func immediateEmpty() -> ModelRootFactory {
        
        return .init(
            httpClientFactory: HTTPClientFactorySpy(),
            logger: LoggerSpy(),
            model: .mockWithEmptyExcept(),
            schedulers: .immediate
        )
    }
    
    static func test(
        httpClientFactory: any HTTPClientFactory = HTTPClientFactorySpy(),
        logger: any LoggerAgentProtocol = LoggerSpy(),
        model: Model = .mockWithEmptyExcept(),
        schedulers: Schedulers
    ) -> ModelRootFactory {
        
        return .init(
            httpClientFactory: httpClientFactory, 
            logger: logger,
            model: model,
            schedulers: schedulers
        )
    }
}

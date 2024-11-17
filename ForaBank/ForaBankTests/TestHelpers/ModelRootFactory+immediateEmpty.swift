//
//  ModelRootFactory+immediateEmpty.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank

extension ModelRootFactory {
    
    static func immediateEmpty() -> ModelRootFactory {
        
        return .init(
            httpClientFactory: HTTPClientFactorySpy(),
            logger: LoggerSpy(),
            model: .mockWithEmptyExcept(),
            schedulers: .immediate
        )
    }
}

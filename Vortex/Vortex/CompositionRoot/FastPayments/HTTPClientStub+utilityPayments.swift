//
//  HTTPClientStub+utilityPayments.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.02.2024.
//

import Foundation

extension UtilityPaymentsEndpointStub {
    
    /// Change this stub with feature flag set to `.active(.stub)` to test.
    static let `default`: Self = .init(
    )
}

extension HTTPClientStub {
    
    static func utilityPayments(
        _ stub: UtilityPaymentsEndpointStub = .default,
        delay: DispatchTimeInterval = .seconds(1)
    ) -> HTTPClientStub {
        
        .init(stub.httpClientStub, delay: delay)
    }
}

struct UtilityPaymentsEndpointStub {
    
    var httpClientStub: [Services.Endpoint.ServiceName: [Data]] {
        
        [:]
    }
}

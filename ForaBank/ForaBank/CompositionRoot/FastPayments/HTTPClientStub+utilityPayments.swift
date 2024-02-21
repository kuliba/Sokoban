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
        delay: TimeInterval = 1
    ) -> HTTPClientStub {
        
        let stub = stub.httpClientStub
            .mapValues { $0.map { $0.response(statusCode: 200) }}
            .mapValues(HTTPClientStub.Response.multiple)
        
        return .init(stub: stub, delay: delay)
    }
}

struct UtilityPaymentsEndpointStub {
    
    var httpClientStub: [Services.Endpoint.ServiceName: [Data]] {
        
        [:]
    }
}

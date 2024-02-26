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
        
        let stub = stub.httpClientStub
            .mapValues { $0.map { $0.response(statusCode: 200) }}
            .mapValues(HTTPClientStub.DelayedResponse.Response.multiple)
            .mapValues {
                
                HTTPClientStub.DelayedResponse(
                    response: $0,
                    delay: delay
                )
            }

        return .init(stub: stub)
    }
}

struct UtilityPaymentsEndpointStub {
    
    var httpClientStub: [Services.Endpoint.ServiceName: [Data]] {
        
        [:]
    }
}

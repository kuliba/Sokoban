//
//  ResponseMapper+mapGetSavingsAccountInfoResponse.swift
//
//
//  Created by Andryusina Nataly on 25.02.2025.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
        
    static func mapGetSavingsAccountInfoResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetSavingsAccountInfoResponse> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> GetSavingsAccountInfoResponse {
        
        .init(
            dateNext: data.dateNext,
            interestAmount: data.interestAmount,
            interestPaid: data.interestPaid,
            minRest: data.minRest
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let dateNext: String?
        let interestAmount: Double?
        let interestPaid: Double?
        let minRest: Double?
    }
}

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
            dateSettlement: data.dateSettlement,
            dateStart: data.dateStart,
            daysLeft: data.daysLeft,
            daysLeftText: data.daysLeftText,
            interestAmount: data.interestAmount,
            interestPaid: data.interestPaid,
            isNeedTopUp: data.isNeedTopUp,
            isPercentBurned: data.isPercentBurned,
            minRest: data.minRest
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let dateNext: String?
        let dateSettlement: String?
        let dateStart: String?
        let daysLeft: Int?
        let daysLeftText: String?
        let interestAmount: Double?
        let interestPaid: Double?
        let isNeedTopUp: Bool?
        let isPercentBurned: Bool?
        let minRest: Double?
    }
}

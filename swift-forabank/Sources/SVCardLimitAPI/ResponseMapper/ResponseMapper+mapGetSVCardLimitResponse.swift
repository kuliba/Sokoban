//
//  ResponseMapper+mapGetSVCardLimitResponse.swift
//
//
//  Created by Andryusina Nataly on 18.06.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    typealias GetProductDynamicParamsListResult = MappingResult<GetSVCardLimitResponse>

    static func mapGetSVCardLimitResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetProductDynamicParamsListResult {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _DTO
    ) throws -> GetSVCardLimitResponse {
        return data.data
    }
}

private extension ResponseMapper._DTO {
    
    var data: GetSVCardLimitResponse {
        
        guard let limitsList else {
            return .init(limitsList: [], serial: serial)
        }
        return .init(limitsList: limitsList.map { $0.dto }, serial: serial)
    }
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let serial: String?
        let limitsList: [_LimitItem]?
                
        struct _LimitItem: Decodable {
            
            let limitType: String
            let limit: [_Limit]
                        
            struct _Limit: Decodable {
               
                let currency: Int
                let currentValue: Double?
                let name: String
                let value: Double?
            }
        }
    }
}

private extension ResponseMapper._DTO._LimitItem {
    
    var dto: GetSVCardLimitResponse.LimitItem {
        
        .init(
            type: self.limitType,
            limits: self.limit.map { $0.dto })
    }
}

private extension ResponseMapper._DTO._LimitItem._Limit {
    
    var dto: GetSVCardLimitResponse.LimitItem.Limit {
        
        .init(
            currency: self.currency,
            currentValue: Decimal(self.currentValue ?? 0),
            name: self.name,
            value: Decimal(self.value ?? 0)
        )
    }
}

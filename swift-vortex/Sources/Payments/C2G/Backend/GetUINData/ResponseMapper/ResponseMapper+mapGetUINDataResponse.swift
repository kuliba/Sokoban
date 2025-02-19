//
//  ResponseMapper+mapGetUINDataResponse.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetUINDataResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetUINDataResponse> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
}

private extension ResponseMapper {
    
    static func map(
        _ data: _DTO
    ) throws -> GetUINDataResponse {
        
        try data.response
    }
    
    struct _DTO: Decodable {
        
        let termsCheck: Bool?
        let transAmm: Decimal?
        let purpose: String?
        let merchantName: String?
        let dateN: String?
        let legalAct: String?
        let paymentTerm: String?
        let discountFixedValue: Decimal?
        let discountExpiry: String?
        let discountSizeValue: Decimal?
        let multiplierSizeValue: Decimal?
        let payerName: String?
        let payerINN: String?
        let payerKPP: String?
        let url: String?
        let UIN: String?
    }
}

private extension ResponseMapper._DTO {
    
    var response: ResponseMapper.GetUINDataResponse {
        
        get throws {
            
            guard let UIN else { throw MissingMandatoryFields() }

            return .init(
                termsCheck: termsCheck,
                transAmm: transAmm,
                purpose: purpose,
                merchantName: merchantName,
                dateN: dateN,
                legalAct: legalAct,
                paymentTerm: paymentTerm,
                discountFixedValue: discountFixedValue,
                discountExpiry: discountExpiry,
                discountSizeValue: discountSizeValue,
                multiplierSizeValue: multiplierSizeValue,
                payerName: payerName,
                payerINN: payerINN,
                payerKPP: payerKPP,
                url: url.flatMap { URL(string: $0) },
                uin: UIN
            )
        }
    }
    
    struct MissingMandatoryFields: Error {}
}


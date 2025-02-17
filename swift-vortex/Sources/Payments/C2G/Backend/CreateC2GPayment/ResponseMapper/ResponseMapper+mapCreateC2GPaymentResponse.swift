//
//  ResponseMapper+mapCreateC2GPaymentResponse.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapCreateC2GPaymentResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CreateC2GPaymentResponse> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
}

private extension ResponseMapper {
    
    static func map(
        _ data: _DTO
    ) throws -> CreateC2GPaymentResponse {
        
        try data.response
    }
    
    struct _DTO: Decodable {
        
        let paymentOperationDetailId: Int?
        let documentStatus: String?
        let productOrderingResponseMessage: String?
        let amount: Decimal?
        let merchantName: String?
        let purpose: String?
    }
}

private extension ResponseMapper._DTO {
    
    var response: ResponseMapper.CreateC2GPaymentResponse {
        
        get throws {
            
            guard let paymentOperationDetailId,
                  let documentStatus,
                  !documentStatus.isEmpty
            else { throw MissingMandatoryFields() }
            
            return .init(
                amount: amount,
                documentStatus: documentStatus,
                merchantName: merchantName,
                message: productOrderingResponseMessage,
                paymentOperationDetailID: paymentOperationDetailId,
                purpose: purpose
            )
        }
    }
    
    struct MissingMandatoryFields: Error {}
}


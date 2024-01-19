//
//  ResponseMapper+mapUpdateFastPaymentContractResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias UpdateFastPaymentContractResult = VoidMappingResult
    
    static func mapUpdateFastPaymentContractResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> UpdateFastPaymentContractResult {
        
        mapToVoid(data, httpURLResponse)
    }
}

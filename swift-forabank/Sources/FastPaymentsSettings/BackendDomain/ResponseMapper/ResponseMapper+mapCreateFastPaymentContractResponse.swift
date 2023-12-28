//
//  ResponseMapper+mapCreateFastPaymentContractResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias CreateFastPaymentContractResult = OkMappingResult
    
    static func mapCreateFastPaymentContractResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> CreateFastPaymentContractResult {
        
        mapToOk(data, httpURLResponse)
    }
}

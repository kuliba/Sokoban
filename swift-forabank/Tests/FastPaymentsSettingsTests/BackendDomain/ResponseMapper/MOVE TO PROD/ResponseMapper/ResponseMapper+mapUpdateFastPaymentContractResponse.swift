//
//  ResponseMapper+mapUpdateFastPaymentContractResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import Foundation

extension ResponseMapper {
    
    typealias UpdateFastPaymentContractResult = OkMappingResult
    
    static func mapUpdateFastPaymentContractResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> UpdateFastPaymentContractResult {
        
        mapToOk(data, httpURLResponse)
    }
}

//
//  ResponseMapper+mapUpdateFastPaymentContractResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import Foundation

extension ResponseMapper {
    
    typealias UpdateFastPaymentContractResult = Result<Void, MappingError>
    
    static func mapUpdateFastPaymentContractResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> UpdateFastPaymentContractResult {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> Void {
        
        if data != nil { throw InvalidResponse() }
    }
    
    private struct InvalidResponse: Error {}
    
    private typealias _Data = Data?
}

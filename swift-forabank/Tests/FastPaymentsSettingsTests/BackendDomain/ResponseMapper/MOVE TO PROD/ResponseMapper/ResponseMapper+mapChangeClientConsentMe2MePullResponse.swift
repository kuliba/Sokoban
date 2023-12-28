//
//  ResponseMapper+mapChangeClientConsentMe2MePullResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import Foundation

extension ResponseMapper {
    
    typealias ChangeClientConsentMe2MePullResult = Result<Void, MappingError>
    
    static func mapChangeClientConsentMe2MePullResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ChangeClientConsentMe2MePullResult {
        
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

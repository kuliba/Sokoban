//
//  ResponseMapper+mapGetBankDefaultResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import Foundation

extension ResponseMapper {
    #warning("change error type to add limit error")
    typealias GetBankDefaultResult = Result<GetBankDefault, MappingError>
    
    static func mapGetBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetBankDefaultResult {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> GetBankDefault {
        
        .init(data.foraBank)
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let foraBank: Bool
    }
}

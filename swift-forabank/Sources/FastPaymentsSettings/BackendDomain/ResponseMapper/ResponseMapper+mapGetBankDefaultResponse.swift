//
//  ResponseMapper+mapGetBankDefaultResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
        
    static func mapGetBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<BankDefault> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> BankDefault {
        
        .init(data.foraBank)
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let foraBank: Bool
    }
}

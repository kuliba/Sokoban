//
//  ResponseMapper+mapPrepareSetBankDefaultResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapPrepareSetBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> VoidMappingResult {
        
        mapToVoid(data, httpURLResponse)
    }
}

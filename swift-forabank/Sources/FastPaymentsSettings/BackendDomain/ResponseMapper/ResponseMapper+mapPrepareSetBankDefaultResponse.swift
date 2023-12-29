//
//  ResponseMapper+mapPrepareSetBankDefaultResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias PrepareSetBankDefaultResult = VoidMappingResult
    
    static func mapPrepareSetBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> PrepareSetBankDefaultResult {
        
        mapToVoid(data, httpURLResponse)
    }
}

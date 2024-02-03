//
//  ResponseMapper+mapMakeSetBankDefaultResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias MakeSetBankDefaultResponseResult = VoidMappingResult
    
    static func mapMakeSetBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MakeSetBankDefaultResponseResult {
        
        mapToVoid(data, httpURLResponse)
    }
}

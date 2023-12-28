//
//  ResponseMapper+mapChangeClientConsentMe2MePullResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias ChangeClientConsentMe2MePullResult = OkMappingResult
    
    static func mapChangeClientConsentMe2MePullResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ChangeClientConsentMe2MePullResult {
        
        mapToOk(data, httpURLResponse)
    }
}

//
//  ResponseMapper+mapChangeSVCardLimitResponse.swift
//
//
//  Created by Andryusina Nataly on 14.06.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapChangeSVCardLimitResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> VoidMappingResult {
        
        mapToVoid(data, httpURLResponse)
    }
}

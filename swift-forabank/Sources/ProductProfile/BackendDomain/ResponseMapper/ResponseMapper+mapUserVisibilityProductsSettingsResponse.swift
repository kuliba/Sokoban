//
//  ResponseMapper+mapUserVisibilityProductsSettingsResponse.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapUserVisibilityProductsSettingsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> VoidMappingResult {
        
        mapToVoid(data, httpURLResponse)
    }
}

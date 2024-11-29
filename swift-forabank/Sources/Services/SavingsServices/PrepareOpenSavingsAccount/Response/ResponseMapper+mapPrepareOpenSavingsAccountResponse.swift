//
//  ResponseMapper+mapPrepareOpenSavingsAccountResponse.swift
//
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapPrepareOpenSavingsAccountResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> VoidMappingResult {
        
        mapToVoid(data, httpURLResponse)
    }
}

//
//  ResponseMapper+mapPrepareDeleteBankDefaultResponse.swift
//  
//
//  Created by Дмитрий Савушкин on 29.09.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapPrepareDeleteBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> VoidMappingResult {
        
        mapToVoid(data, httpURLResponse)
    }
}

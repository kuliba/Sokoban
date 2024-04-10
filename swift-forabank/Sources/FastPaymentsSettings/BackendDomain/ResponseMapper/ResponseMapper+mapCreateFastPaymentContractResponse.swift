//
//  ResponseMapper+mapCreateFastPaymentContractResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapCreateFastPaymentContractResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> VoidMappingResult {
        
        mapToVoid(data, httpURLResponse)
    }
}

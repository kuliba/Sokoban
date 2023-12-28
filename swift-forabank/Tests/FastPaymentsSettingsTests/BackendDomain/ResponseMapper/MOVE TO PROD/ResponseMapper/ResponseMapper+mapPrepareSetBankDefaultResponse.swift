//
//  ResponseMapper+mapPrepareSetBankDefaultResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import Foundation

extension ResponseMapper {
    
    typealias PrepareSetBankDefaultResult = OkMappingResult
    
    static func mapPrepareSetBankDefaultResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> PrepareSetBankDefaultResult {
        
        mapToOk(data, httpURLResponse)
    }
}

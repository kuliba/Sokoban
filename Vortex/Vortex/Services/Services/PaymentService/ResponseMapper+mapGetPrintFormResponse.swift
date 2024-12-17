//
//  ResponseMapper+mapGetPrintFormResponse.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias GetPrintFormResult = Result<Data, GetPrintFormError>
    
    // TODO: has the same shape as mapOperationDetailByPaymentIDResponse - make generic
    static func mapGetPrintFormResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetPrintFormResult {
        
        switch httpURLResponse.statusCode {
        case 200:
            return .success(data)
            
        default:
            return .failure(GetPrintFormError())
        }
    }
    
    struct GetPrintFormError: Error {}
}

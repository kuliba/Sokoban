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
        
        typealias Response = ResponseMapper.ServerResponse<Data>
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                let response = try JSONDecoder().decode(Response.self, from: data)
                let data = try response.data.get(orThrow: NSError(domain: "Empty data", code: -1))
                if let errorMessage = response.errorMessage {
                    return .failure(.server(statusCode: response.statusCode, errorMessage: errorMessage))
                } else {
                    return .success(data)
                }
                
            default:
                let error = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.server(statusCode: error.statusCode, errorMessage: error.errorMessage))
            }
        } catch {
            return .failure(.invalidData(statusCode: httpURLResponse.statusCode, data: data))
        }
    }
    
    enum GetPrintFormError: Error {
        
        case invalidData(statusCode: Int, data: Data)
        case server(statusCode: Int, errorMessage: String)
    }
}

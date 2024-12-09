//
//  ResponseMapper+mapOperationDetailByPaymentIDResponse.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.11.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias OperationDetailByPaymentIDResult = Result<OperationDetailData, OperationDetailByPaymentIDError>
    
    static func mapOperationDetailByPaymentIDResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> OperationDetailByPaymentIDResult {
        
        typealias Response = ResponseMapper.ServerResponse<OperationDetailData>
        
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
    
    enum OperationDetailByPaymentIDError: Error {
        
        case invalidData(statusCode: Int, data: Data)
        case server(statusCode: Int, errorMessage: String)
    }
}

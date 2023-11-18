//
//  ResponseMapper+MakeTransfer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.11.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias MakeTransferResult = Result<MakeTransferResponse, MakeTransferError>
    
    static func mapMakeTransferResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MakeTransferResult {
        
        do {
            
            switch httpURLResponse.statusCode {
            case 200:
                    
                let commissionProductTransfer = try JSONDecoder().decode(MakeTransferResponse.self, from: data)
                return .success(commissionProductTransfer)
                
            default:
                
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.error(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
            
        } catch {
            return .failure(.invalidData(
                statusCode: httpURLResponse.statusCode, data: data
            ))
            
        }
    }
    
    enum MakeTransferError: Error , Equatable{
        
        case error(
            statusCode: Int,
            errorMessage: String
        )
        case invalidData(statusCode: Int, data: Data)
    }
}

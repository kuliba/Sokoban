//
//  ResponseMapper+CommissionProductTransfer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.11.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias StickerCommissionProductResult = Result<CommissionProductTransferResponse, CommissionProductTransferError>
    
    static func mapCommissionProductTransferResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> StickerCommissionProductResult {
        
        do {
            
            switch httpURLResponse.statusCode {
            case 200:
                    
                let commissionProductTransfer = try JSONDecoder().decode(CommissionProductTransferResponse.self, from: data)
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
    
    enum CommissionProductTransferError: Error , Equatable{
        
        case error(
            statusCode: Int,
            errorMessage: String
        )
        case invalidData(statusCode: Int, data: Data)
    }
}

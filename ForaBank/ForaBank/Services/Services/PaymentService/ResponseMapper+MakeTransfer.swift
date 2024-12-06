//
//  ResponseMapper+MakeTransfer.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 09.11.2023.
//

import Foundation
import PaymentSticker

extension ResponseMapper {
    
    typealias MakeTransferResult = Result<MakeTransfer, MakeTransferError>
    
    static func mapMakeTransferResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MakeTransferResult {
        
        do {
            
            switch httpURLResponse.statusCode {
            case 200:
                
                let makeTransferResponse = try JSONDecoder().decode(
                    MakeTransferResponse.self,
                    from: data
                )
                return .success(makeTransferResponse.response)
                
            default:
                
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.error(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
            
        } catch {
            if let error = try? JSONDecoder().decode(ServerError.self, from: data) {
                
                return .failure(.error(statusCode: error.statusCode, errorMessage: error.errorMessage))
            } else {
             
                return .failure(.invalidData(
                    statusCode: httpURLResponse.statusCode, data: data
                ))
            }
        }
    }
}

extension ResponseMapper {
    
    private struct MakeTransferResponse: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: Data

        var response: MakeTransfer {
            
            .init(
                paymentOperationDetailId: data.paymentOperationDetailId,
                documentStatus: data.documentStatus,
                productOrderingResponseMessage: data.productOrderingResponseMessage
            )
        }
        
        struct Data: Decodable {
            
            let paymentOperationDetailId: Int
            let documentStatus: String
            let productOrderingResponseMessage: String
        }
    }
}

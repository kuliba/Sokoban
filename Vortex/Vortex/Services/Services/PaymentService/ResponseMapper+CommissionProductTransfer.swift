//
//  ResponseMapper+CommissionProductTransfer.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 09.11.2023.
//

import Foundation
import PaymentSticker

extension ResponseMapper {
    
    typealias StickerCommissionProductResult = Result<CommissionProductTransfer, CommissionProductTransferError>
    
    static func mapCommissionProductTransferResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> StickerCommissionProductResult {
        
        do {
            
            switch httpURLResponse.statusCode {
            case 200:
                    
                let commissionProductTransfer = try JSONDecoder().decode(CommissionProductTransferResponse.self, from: data)
                return .success(commissionProductTransfer.response)
                
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
}

extension ResponseMapper {
    
    public struct CommissionProductTransferResponse: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: Data

        var response: CommissionProductTransfer {
            
            .init(
                paymentOperationDetailId: data.paymentOperationDetailId,
                payerCardId: data.payerCardId,
                payerCardNumber: data.payerCardNumber,
                payerAccountId: data.payerAccountId,
                payerAccountNumber: data.payerAccountNumber,
                payeeCardNumber: data.payeeCardNumber,
                payeeAccountNumber: data.payeeAccountNumber,
                payeeName: data.payeeName,
                amount: data.amount,
                debitAmount: data.debitAmount,
                currencyAmount: data.currencyAmount,
                currencyPayer: data.currencyPayer,
                currencyPayee: data.currencyPayee,
                currencyRate: data.currencyRate,
                creditAmount: data.creditAmount,
                documentStatus: data.documentStatus
            )
        }
        
        struct Data: Decodable {
            
            let paymentOperationDetailId: Int
            let payerCardId: Int?
            let payerCardNumber: String?
            let payerAccountId: String?
            let payerAccountNumber: String?
            let payeeCardNumber: String?
            let payeeAccountNumber: String?
            let payeeName: String
            let amount: Decimal
            let debitAmount: Decimal
            let currencyAmount: String
            let currencyPayer: String
            let currencyPayee: String
            let currencyRate: String?
            let creditAmount: Decimal?
            let documentStatus: String?
        }
    }
}

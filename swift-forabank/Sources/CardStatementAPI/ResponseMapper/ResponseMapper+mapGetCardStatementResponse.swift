//
//  ResponseMapper+mapGetCardStatementResponse.swift
//
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

public extension ResponseMapper {
    
    static func mapGetCardStatementResponse(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Swift.Result<[ProductStatementData], MappingError> {
        
        let statusCode = response.statusCode
        
        switch statusCode {
        case statusCode200:
            return handle200(with: data)
            
        default:
            return errorByCode(statusCode)
        }
    }
    
    private static func handle200(with data: Data) -> Swift.Result<[ProductStatementData], MappingError> {
        
        do {
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601)
            
            let response = try decoder.decode(GetCardStatementForPeriodResponse.self, from: data)
            switch response.statusCode {
                
            default:
                guard let data = response.data
                else { return .failure(.mappingFailure(response.errorMessage ?? .defaultError))}
                return .success(data.map { .init(data: $0) })
            }
        } catch {
            return .failure(.mappingFailure(.defaultError))
        }
    }
    
    private static func errorByCode(
        _ code: Int
    ) -> Swift.Result<[ProductStatementData], MappingError> {
        
        .failure(.mappingFailure(HTTPURLResponse.localizedString(forStatusCode: code)))
    }
}

private let statusCode200 = 200

public extension String {
    
    static let defaultError: Self = "Возникла техническая ошибка"
}

private struct GetCardStatementForPeriodResponse: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: [Response]?
}

private extension ProductStatementData {
    
    init(
        data: Response
    ) {
                
        let fastPayment: ProductStatementData.FastPayment? = data.fastPayment.map {
            .init(data: $0)
        }
        
        self = .init(
            type: data.type.value,
            accountID: data.accountID,
            operationType: data.operationType.value,
            paymentDetailType: data.paymentDetailType.value,
            amount: data.amountValue,
            documentAmount: data.documentAmountValue,
            comment: data.comment,
            documentID: data.documentID,
            accountNumber: data.accountNumber,
            currencyCodeNumeric: data.currencyCodeNumeric,
            merchantName: data.merchantName,
            merchantNameRus: data.merchantNameRus,
            groupName: data.groupName,
            md5hash: data.md5hash,
            svgImage: data.svgImage,
            fastPayment: fastPayment,
            terminalCode: data.terminalCode,
            deviceCode: data.deviceCode,
            country: data.country,
            city: data.city,
            operationId: data.operationId,
            isCancellation: data.isCancellation,
            cardTranNumber: data.cardTranNumber,
            opCode: data.opCode,
            date: data.date,
            tranDate: data.tranDate,
            MCC: data.MCC)
    }
}

private extension ProductStatementData.FastPayment {
    
    init(
        data: Response.FastPayment
    ) {
        self = .init(
            opkcid: data.opkcid,
            foreignName: data.foreignName,
            foreignPhoneNumber: data.foreignPhoneNumber,
            foreignBankBIC: data.foreignBankBIC,
            foreignBankID: data.foreignBankID,
            foreignBankName: data.foreignBankName,
            documentComment: data.documentComment,
            operTypeFP: data.operTypeFP,
            tradeName: data.tradeName,
            guid: data.guid)
    }
}

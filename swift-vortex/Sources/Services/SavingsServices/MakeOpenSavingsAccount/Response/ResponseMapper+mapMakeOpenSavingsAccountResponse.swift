//
//  ResponseMapper+mapMakeOpenSavingsAccountResponse.swift
//
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
        
    static func mapMakeOpenSavingsAccountResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<MakeOpenSavingsAccountResponse> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> MakeOpenSavingsAccountResponse {
        
        .init(
            documentInfo: .init(data),
            paymentInfo: .init(data),
            paymentOperationDetailID: data.paymentOperationDetailId)
    }
}

private extension MakeOpenSavingsAccountResponse.DocumentInfo {
    
    init(_ data: ResponseMapper._Data) {
        
        self.init(
            documentStatus: .init(data.documentStatus),
            needMake: data.needMake ?? false,
            needOTP: data.needOTP ?? false,
            scenario: .init(data.scenario))
    }
}

private extension MakeOpenSavingsAccountResponse.PaymentInfo {
    
    init(_ data: ResponseMapper._Data) {
        
        self.init(
            amount: data.amount,
            accountNumber: data.accountNumber, 
            accountId: data.accountId,
            creditAmount: data.creditAmount,
            currencyAmount: data.currencyAmount,
            currencyPayee: data.currencyPayee,
            currencyPayer: data.currencyPayer,
            currencyRate: data.currencyRate, 
            dateOpen: data.dateOpen,
            debitAmount: data.debitAmount,
            fee: data.fee,
            payeeName: data.payeeName)
    }
}

private extension MakeOpenSavingsAccountResponse.DocumentStatus {
    
    init?(_ rawValue: String?) {
        
        switch rawValue {
        case "COMPLETE":    self = .complete
        case "IN_PROGRESS": self = .inProgress
        case "REJECTED":    self = .rejected
        default:            return nil
        }
    }
}

private extension MakeOpenSavingsAccountResponse.AntiFraudScenario {
    
    init?(_ rawValue: String?) {
        
        switch rawValue {
        case "OK":                  self = .ok
        case "SCOR_SUSPECT_FRAUD": self = .suspect
        default:                    return nil
        }
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let amount: Decimal?
        let accountNumber: String?
        let accountId: Int?
        let creditAmount: Decimal?
        let currencyAmount: String?
        let currencyPayee: String?
        let currencyPayer: String?
        let currencyRate: Decimal?
        let dateOpen: String?
        let debitAmount: Decimal?
        let documentStatus: String?
        let fee: Decimal?
        let needMake: Bool?
        let needOTP: Bool?
        let payeeName: String?
        let paymentOperationDetailId: Int?
        let scenario: String?
    }
}

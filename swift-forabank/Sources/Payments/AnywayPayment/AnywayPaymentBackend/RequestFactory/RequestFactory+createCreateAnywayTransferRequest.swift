//
//  RequestFactory+createCreateAnywayTransferRequest.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import Foundation
import RemoteServices
import Tagged

public extension RequestFactory {
    
    static func createCreateAnywayTransferRequest(
        url: URL,
        payload: CreateAnywayTransferPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

extension RequestFactory {
    
    public struct CreateAnywayTransferPayload: Equatable {
        
        public let additionals: [Additional]
        public let amount: Decimal?
        public let check: Bool
        public let comment: String?
        public let currencyAmount: String?
        public let mcc: String?
        public let payer: Payer?
        public let puref: String?
        
        public init(
            additionals: [Additional],
            amount: Decimal? = nil,
            check: Bool,
            comment: String? = nil,
            currencyAmount: String? = nil,
            mcc: String? = nil,
            payer: Payer? = nil,
            puref: String? = nil
        ) {
            self.additionals = additionals
            self.amount = amount
            self.check = check
            self.comment = comment
            self.currencyAmount = currencyAmount
            self.mcc = mcc
            self.payer = payer
            self.puref = puref
        }
    }
}

extension RequestFactory.CreateAnywayTransferPayload {
    
    public struct Additional: Equatable {
        
        public let fieldID: Int
        public let fieldName: String
        public let fieldValue: String
        
        public init(
            fieldID: Int,
            fieldName: String,
            fieldValue: String
        ) {
            self.fieldID = fieldID
            self.fieldName = fieldName
            self.fieldValue = fieldValue
        }
    }
    
    public struct Payer: Equatable {
        
        public let accountID: Int?
        public let accountNumber: String?
        public let cardID: Int?
        public let cardNumber: String?
        public let inn: String?
        public let phoneNumber: String?
        
        public init(
            accountID: Int? = nil,
            accountNumber: String? = nil,
            cardID: Int? = nil,
            cardNumber: String? = nil,
            inn: String? = nil,
            phoneNumber: String? = nil
        ) {
            self.accountID = accountID
            self.accountNumber = accountNumber
            self.cardID = cardID
            self.cardNumber = cardNumber
            self.inn = inn
            self.phoneNumber = phoneNumber
        }
    }
}

private extension RequestFactory.CreateAnywayTransferPayload {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONEncoder().encode(RequestFactory._DTO(self))
        }
    }
}

private extension RequestFactory._DTO {
    
    init(_ payload: RequestFactory.CreateAnywayTransferPayload) {
        
        self.init(
            additional: payload.additionals.map { .init($0) },
            amount: payload.amount,
            check: payload.check,
            comment: payload.comment,
            currencyAmount: payload.currencyAmount,
            mcc: payload.mcc,
            payer: payload.payer.map { .init($0) },
            puref: payload.puref
        )
    }
}

private extension RequestFactory {
    
    struct _DTO: Codable, Equatable {
        
        let additional: [_Additional]
        let amount: Decimal?
        let check: Bool
        let comment: String?
        let currencyAmount: String?
        let mcc: String?
        let payer: _Payer?
        let puref: String?
    }
}

private extension RequestFactory._DTO {
    
    struct _Additional: Codable, Equatable {
        
        let fieldid: Int
        let fieldname: String
        let fieldvalue: String
    }
    
    struct _Payer: Codable, Equatable {
        
        let accountId: Int?
        let accountNumber: String?
        let cardId: Int?
        let cardNumber: String?
        let inn: String?
        let phoneNumber: String?
    }
}

private extension RequestFactory._DTO._Additional {
    
    init(_ additional: RequestFactory.CreateAnywayTransferPayload.Additional) {
        
        self.init(
            fieldid: additional.fieldID,
            fieldname: additional.fieldName,
            fieldvalue: additional.fieldValue
        )
    }
}

private extension RequestFactory._DTO._Payer {
    
    init(_ payer: RequestFactory.CreateAnywayTransferPayload.Payer) {
        
        self.init(
            accountId: payer.accountID,
            accountNumber: payer.accountNumber,
            cardId: payer.cardID,
            cardNumber: payer.cardNumber,
            inn: payer.inn,
            phoneNumber: payer.phoneNumber
        )
    }
}

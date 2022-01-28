//
//  TransferData.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation

class TransferData: TransferAbstractData {

    let payeeExternal: PayeeExternal?
    let payeeInternal: PayeeInternal?
    
    internal init(amount: Double?, check: Bool, comment: String?, currencyAmount: String, payer: Payer, payeeExternal: PayeeExternal?, payeeInternal: PayeeInternal?) {
        
        self.payeeExternal = payeeExternal
        self.payeeInternal = payeeInternal
        
        super.init(amount: amount, check: check, comment: comment, currencyAmount: currencyAmount, payer: payer)
    }
    
    //MARK: Codable
    
    private enum CodingKeys : String, CodingKey {
        case payeeExternal, payeeInternal
    }
    
    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        payeeExternal = try container.decodeIfPresent(PayeeExternal.self, forKey: .payeeExternal)
        payeeInternal = try container.decodeIfPresent(PayeeInternal.self, forKey: .payeeInternal)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(payeeExternal, forKey: .payeeExternal)
        try container.encode(payeeInternal, forKey: .payeeInternal)
        
        try super.encode(to: encoder)
    }
    
    //MARK: Equitable
    
    static func == (lhs: TransferData, rhs: TransferData) -> Bool {
        
        return  lhs.amount == rhs.amount &&
                lhs.check == rhs.check &&
                lhs.comment == rhs.comment &&
                lhs.currencyAmount == rhs.currencyAmount &&
                lhs.payer == rhs.payer &&
                lhs.payeeExternal == rhs.payeeExternal &&
                lhs.payeeInternal == rhs.payeeInternal
    }
}

extension TransferData {
    
    struct PayeeExternal: Codable, Equatable {
        
        let inn: String
        let kpp: String?
        let accountId: Int?
        let accountNumber: String
        let bankBIC: String
        let cardId: Int?
        let cardNumber: String?
        let compilerStatus: String?
        let date: String?
        let name: String
        let tax: Tax
        
        struct Tax: Codable, Equatable {
            
            let bcc: String?
            let date: String?
            let documentNumber: String?
            let documentType: String?
            let oktmo: String?
            let period: String?
            let reason: String?
            let uin: String?
        }
        
        private enum CodingKeys : String, CodingKey {
            case inn = "INN", kpp = "KPP", accountId, accountNumber, bankBIC, cardId, cardNumber, compilerStatus, date, name, tax
        }
    }
}

extension TransferData {
    
    struct PayeeInternal: Codable, Equatable {
        
        let accountId: Int?
        let accountNumber: String?
        let cardId: Int?
        let cardNumber: String?
        let phoneNumber: String?
        let productCustomName: String?
    }
}

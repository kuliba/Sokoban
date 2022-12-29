//
//  TransferGeneralData.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation

class TransferGeneralData: TransferData {

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
    
    static func == (lhs: TransferGeneralData, rhs: TransferGeneralData) -> Bool {
        
        return  lhs.amount == rhs.amount &&
                lhs.check == rhs.check &&
                lhs.comment == rhs.comment &&
                lhs.currencyAmount == rhs.currencyAmount &&
                lhs.payer == rhs.payer &&
                lhs.payeeExternal == rhs.payeeExternal &&
                lhs.payeeInternal == rhs.payeeInternal
    }
}

extension TransferGeneralData {
    
    struct PayeeExternal: Codable, Equatable {
        
        let inn: String?
        let kpp: String?
        let accountId: Int?
        let accountNumber: String
        let bankBIC: String?
        let cardId: Int?
        let cardNumber: String?
        let compilerStatus: String?
        let date: String?
        let name: String
        let tax: Tax?
        
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

extension TransferGeneralData {
    
    struct PayeeInternal: Codable, Equatable {

        let accountId: Int?
        let accountNumber: String?
        let cardId: Int?
        let cardNumber: String?
        let phoneNumber: String?
        let productCustomName: String?
        
        init(accountId: Int?, accountNumber: String?, cardId: Int?, cardNumber: String?, phoneNumber: String?, productCustomName: String?) {
            self.accountId = accountId
            self.accountNumber = accountNumber
            self.cardId = cardId
            self.cardNumber = cardNumber
            self.phoneNumber = phoneNumber
            self.productCustomName = productCustomName
        }
        
        init?(productData: ProductData) {
            
            switch productData {
            case let card as ProductCardData:
               
                self = .init(accountId: nil, accountNumber: nil,
                             cardId: card.id,
                             cardNumber: nil, phoneNumber: nil, productCustomName: nil)
                
            case let account as ProductAccountData:
               
                self = .init(accountId: account.id,
                             accountNumber: nil, cardId: nil, cardNumber: nil,
                             phoneNumber: nil, productCustomName: nil)
                
            case let deposit as ProductDepositData:
               
                self = .init(accountId: deposit.accountId,
                             accountNumber: nil, cardId: nil, cardNumber: nil,
                             phoneNumber: nil, productCustomName: nil)
                
            default: return nil
            }
        }
    }
}


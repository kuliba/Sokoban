//
//  AbstractTransfer.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation

class TransferData: Codable {

    let amount: Double?
    let check: Bool
    let comment: String?
    let currencyAmount: String
    let payer: Payer
    
    internal init(amount: Double?, check: Bool, comment: String?, currencyAmount: String, payer: Payer) {
        
        self.amount = amount
        self.check = check
        self.comment = comment
        self.currencyAmount = currencyAmount
        self.payer = payer
    }
    
    //MARK: Codable
    
    private enum CodingKeys : String, CodingKey {
        case amount, check, comment, currencyAmount, payer
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decodeIfPresent(Double.self, forKey: .amount)
        check = try container.decode(Bool.self, forKey: .check)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        currencyAmount = try container.decode(String.self, forKey: .currencyAmount)
        payer = try container.decode(Payer.self, forKey: .payer)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(check, forKey: .check)
        try container.encode(comment, forKey: .comment)
        try container.encode(currencyAmount, forKey: .currencyAmount)
        try container.encode(payer, forKey: .payer)
    }
}

extension TransferData {
    
    struct Payer: Codable, Equatable, CustomDebugStringConvertible {
        
        let inn: String?
        let accountId: Int?
        let accountNumber: String?
        let cardId: Int?
        let cardNumber: String?
        let phoneNumber: String?
        
        var debugDescription: String {
            
            "cardId: \(String(describing: cardId)), accountId: \(String(describing: accountId))"
        }
    }
}

extension TransferData: Equatable {
    
    static func == (lhs: TransferData, rhs: TransferData) -> Bool {
        
        return  lhs.amount == rhs.amount &&
                lhs.check == rhs.check &&
                lhs.comment == rhs.comment &&
                lhs.currencyAmount == rhs.currencyAmount &&
                lhs.payer == rhs.payer
    }
}

extension TransferData {
    
    enum Step {
        
        case initial
        case next
        case check
        
        var isNewPayment: Bool { self == .initial }
        var isCheck: Bool { self == .check }
    }
}

extension TransferData: CustomDebugStringConvertible {
    
    @objc
    var debugDescription: String {
        
        "TransferData | amount: \(String(describing: amount)), check: \(String(describing: check)), currencyAmount: \(String(describing: currencyAmount)), payer: \(payer.debugDescription)"
    }
}

extension TransferData.Payer {
    
    init?(productData: ProductData) {
        
        switch productData {
        case let card as ProductCardData:
           
            self = .init(inn: nil, accountId: nil, accountNumber: nil,
                         cardId: card.id,
                         cardNumber: nil, phoneNumber: nil)
            
        case let account as ProductAccountData:
           
            self = .init(inn: nil,
                         accountId: account.id,
                         accountNumber: nil, cardId: nil,
                         cardNumber: nil, phoneNumber: nil)
            
        case let deposit as ProductDepositData:
           
            self = .init(inn: nil, //TODO: after analit
                         accountId: deposit.accountId,
                         accountNumber: nil, cardId: nil,
                         cardNumber: nil, phoneNumber: nil)
            
        default: return nil
        }
    }
}

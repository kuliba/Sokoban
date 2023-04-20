//
//  TransferMe2MeData.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation

class TransferMe2MeData: TransferData {
    
    let bankId: String
    
    init(amount: Decimal?, check: Bool, comment: String?, currencyAmount: String, payer: Payer, bankId: String) {
        
        self.bankId = bankId

        super.init(amount: amount, check: check, comment: comment, currencyAmount: currencyAmount, payer: payer)
    }
    
    //TODO: remove after a switch to a Decimal in the related code in the project
    convenience init(amount: Double?, check: Bool, comment: String?, currencyAmount: String, payer: Payer, bankId: String) {
        
        let amountDecimal: Decimal? = {
            
            guard let amount else {
                return nil
            }
            
            return Decimal(amount).roundedFinance()
        }()
        
        self.init(amount: amountDecimal, check: check, comment: comment, currencyAmount: currencyAmount, payer: payer, bankId: bankId)
    }
    
    //MARK: Codable
    
    private enum CodingKeys : String, CodingKey {
        case bankId
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bankId = try container.decode(String.self, forKey: .bankId)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bankId, forKey: .bankId)
        
        try super.encode(to: encoder)
    }
    
    //MARK: Equitable
    
    static func == (lhs: TransferMe2MeData, rhs: TransferMe2MeData) -> Bool {
        
        return  lhs.amount == rhs.amount &&
                lhs.check == rhs.check &&
                lhs.comment == rhs.comment &&
                lhs.currencyAmount == rhs.currencyAmount &&
                lhs.payer == rhs.payer &&
                lhs.bankId == rhs.bankId 
    }
}

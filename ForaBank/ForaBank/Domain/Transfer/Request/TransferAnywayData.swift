//
//  TransferAnywayData.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation

class TransferAnywayData: TransferData {
    
    let additional: [Additional]
    let puref: String?
    
    init(amount: Decimal?, check: Bool, comment: String?, currencyAmount: String, payer: Payer, additional: [Additional], puref: String?) {
        
        self.additional = additional
        self.puref = puref

        super.init(amount: amount, check: check, comment: comment, currencyAmount: currencyAmount, payer: payer)
    }
    
    //TODO: remove after a switch to a Decimal in the related code in the project
    convenience init(amount: Double?, check: Bool, comment: String?, currencyAmount: String, payer: Payer, additional: [Additional], puref: String?) {
        
        let amountDecimal: Decimal? = {
            
            guard let amount else {
                return nil
            }
            
            return Decimal(amount).roundedFinance()
        }()
        
        self.init(amount: amountDecimal, check: check, comment: comment, currencyAmount: currencyAmount, payer: payer, additional: additional, puref: puref)
    }
    
    //MARK: Codable
    
    private enum CodingKeys : String, CodingKey {
        case additional, puref
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        additional = try container.decode([Additional].self, forKey: .additional)
        puref = try container.decodeIfPresent(String.self, forKey: .puref)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(additional, forKey: .additional)
        try container.encode(puref, forKey: .puref)
        
        try super.encode(to: encoder)
    }
    
    //MARK: Equitable
    
    static func == (lhs: TransferAnywayData, rhs: TransferAnywayData) -> Bool {
        
        return  lhs.amount == rhs.amount &&
                lhs.check == rhs.check &&
                lhs.comment == rhs.comment &&
                lhs.currencyAmount == rhs.currencyAmount &&
                lhs.payer == rhs.payer &&
                lhs.additional == rhs.additional &&
                lhs.puref == rhs.puref
    }
}

extension TransferAnywayData {
    
    struct Additional: Codable, Equatable, CustomDebugStringConvertible {
        
        let fieldid: Int
        let fieldname: String
        let fieldvalue: String
        
        var debugDescription: String {
            
            "id: \(fieldid), name: \(fieldname), value: \(fieldvalue)"
        }
    }
}

extension TransferAnywayData {
    
    override var debugDescription: String {
        
        var additionsDescription = ""
        
        for addition in additional {
            
            additionsDescription += addition.debugDescription
            additionsDescription += " | "
        }
        
        return super.debugDescription + ", puref: \(String(describing: puref))" + ", additional: " + additionsDescription
    }
}

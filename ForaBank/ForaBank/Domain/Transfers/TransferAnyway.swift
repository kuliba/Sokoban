//
//  TransferAnyway.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation

class TransferAnyway: TransferAbstract {
    
    let additional: [Additional]?
    let puref: String?
    
    internal init(amount: Double?, check: Bool, comment: String?, currencyAmount: String, payer: Payer, additional: [Additional]?, puref: String?) {
        
        self.additional = additional
        self.puref = puref

        super.init(amount: amount, check: check, comment: comment, currencyAmount: currencyAmount, payer: payer)
    }
    
    //MARK: Codable
    
    private enum CodingKeys : String, CodingKey {
        case additional, puref
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        additional = try container.decodeIfPresent([Additional].self, forKey: .additional)
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
    
    static func == (lhs: TransferAnyway, rhs: TransferAnyway) -> Bool {
        
        return  lhs.amount == rhs.amount &&
                lhs.check == rhs.check &&
                lhs.comment == rhs.comment &&
                lhs.currencyAmount == rhs.currencyAmount &&
                lhs.payer == rhs.payer &&
                lhs.additional == rhs.additional &&
                lhs.puref == rhs.puref
    }
}

extension TransferAnyway {
    
    struct Additional: Codable, Equatable {
        
        let fieldid: Int?
        let fieldname: String?
        let fieldvalue: String?
    }
}

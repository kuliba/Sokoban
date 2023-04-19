//
//  PaymentServiceData.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/24/22.
//

import Foundation

class PaymentServiceData: LatestPaymentData {
    
    var additionalList: [AdditionalListData]
    var amount: Double
    var puref: String
    var lastPaymentName: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case additionalList, amount, puref
        case lastPaymentName = "lpName"
    }
    
    internal init(additionalList: [AdditionalListData], amount: Double, date: Date, paymentDate: String, puref: String, type: Kind, lastPaymentName: String?) {
        
        self.additionalList = additionalList
        self.amount = amount
        self.puref = puref
        self.lastPaymentName = lastPaymentName
        super.init(date: date, paymentDate: paymentDate, type: type)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        additionalList = try container.decode([AdditionalListData].self, forKey: .additionalList)
        amount = try container.decode(Double.self, forKey: .amount)
        puref = try container.decode(String.self, forKey: .puref)
        lastPaymentName = try container.decodeIfPresent(String.self, forKey: .lastPaymentName)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(additionalList, forKey: .additionalList)
        try container.encode(amount, forKey: .amount)
        try container.encode(puref, forKey: .puref)
        try container.encodeIfPresent(lastPaymentName, forKey: .lastPaymentName)
        
        try super.encode(to: encoder)
    }
}

extension PaymentServiceData {
    
    struct AdditionalListData: Codable, Equatable {
        
        let fieldTitle: String?
        let fieldName: String
        let fieldValue: String
        let svgImage: String?
    }
}

extension PaymentServiceData.AdditionalListData {
    
    var isTrnPickupPoint: Bool {
        
        fieldName == "trnPickupPoint"
    }
    
    var isPhone: Bool {
        
        fieldName == Payments.Parameter.Identifier.countryPhone.rawValue
    }
    
    var isName: Bool {
        
        fieldName == Payments.Parameter.Identifier.countryGivenName.rawValue
    }
    
    var isLastName: Bool {
 
        fieldName == Payments.Parameter.Identifier.countryMiddleName.rawValue
    }
}

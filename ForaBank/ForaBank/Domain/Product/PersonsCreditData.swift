//
//  PersonsCreditData.swift
//  ForaBank
//
//  Created by Дмитрий on 25.03.2022.
//

import Foundation

struct PersonsCreditData: Equatable {

    let loandId: Int
    let clientId: Int
    let currencyCode: String?
    let currencyNumber: Int?
    let currencyId: Int?
    let number: String?
    let datePayment: Date?
    let amountCredit: Double?
    let amountRepaid: Double?
    let amountPayment: Double?
    let overduePayment: Double?
    
    enum CodingKeys: String, CodingKey {
        case loandId = "loanID"
        case clientId = "clientID"
        case currencyId, currencyCode, currencyNumber, number, datePayment, amountCredit, amountRepaid, amountPayment, overduePayment
    }
    
    internal init(loandId: Int, clientId: Int, currencyCode: String?, currencyNumber: Int?, currencyId: Int?, number: String?, datePayment: Date?, amountCredit: Double?, amountRepaid: Double?, amountPayment: Double?, overduePayment: Double?) {
        self.loandId = loandId
        self.clientId = clientId
        self.currencyCode = currencyCode
        self.currencyNumber = currencyNumber
        self.currencyId = currencyId
        self.number = number
        self.datePayment = datePayment
        self.amountCredit = amountCredit
        self.amountRepaid = amountRepaid
        self.amountPayment = amountPayment
        self.overduePayment = overduePayment
    }  
}

extension PersonsCreditData {
    
    var amountCreditValue: Double { amountCredit ?? 0 }
    var amountRepaidValue: Double { amountRepaid ?? 0 }
    var amountPaymentValue: Double { amountPayment ?? 0 }
    var overduePaymentValue: Double { overduePayment ?? 0 }
}

//MARK: - Codable

extension PersonsCreditData: Codable {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        loandId = try container.decode(Int.self, forKey: .loandId)
        clientId = try container.decode(Int.self, forKey: .clientId)
        currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode)
        currencyNumber = try container.decodeIfPresent(Int.self, forKey: .currencyNumber)
        currencyId = try container.decodeIfPresent(Int.self, forKey: .currencyId)
        number = try container.decodeIfPresent(String.self, forKey: .number)
        if let dateValue = try container.decodeIfPresent(Int.self, forKey: .datePayment) {
            
            datePayment = Date(timeIntervalSince1970: TimeInterval(dateValue / 1000))
            
        } else {
            
            datePayment = nil
        }
        amountCredit = try container.decodeIfPresent(Double.self, forKey: .amountCredit)
        amountRepaid = try container.decodeIfPresent(Double.self, forKey: .amountRepaid)
        amountPayment = try container.decodeIfPresent(Double.self, forKey: .amountPayment)
        overduePayment = try container.decodeIfPresent(Double.self, forKey: .overduePayment)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(loandId, forKey: .loandId)
        try container.encode(clientId, forKey: .clientId)
        try container.encodeIfPresent(currencyCode, forKey: .currencyCode)
        try container.encodeIfPresent(currencyNumber, forKey: .currencyNumber)
        try container.encodeIfPresent(currencyId, forKey: .currencyId)
        try container.encodeIfPresent(number, forKey: .number)
        if let datePayment = datePayment {
            
            let dateValue = Int(datePayment.timeIntervalSince1970) * 1000
            try container.encode(dateValue, forKey: .datePayment)
        }
        try container.encodeIfPresent(amountCredit, forKey: .amountCredit)
        try container.encodeIfPresent(amountRepaid, forKey: .amountRepaid)
        try container.encodeIfPresent(amountPayment, forKey: .amountPayment)
        try container.encodeIfPresent(overduePayment, forKey: .overduePayment)
    }
}



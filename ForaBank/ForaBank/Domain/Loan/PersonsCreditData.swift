//
//  PersonsCreditData.swift
//  ForaBank
//
//  Created by Дмитрий on 25.03.2022.
//

import Foundation

struct PersonsCreditItem: Codable, Equatable {
    
    let original: PersonsCreditData?
    let customName: String?
    
    struct PersonsCreditData: Codable, Equatable {
        
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
            case loandId = "loandID"
            case clientId = "clientID"
            case currencyId, currencyCode, currencyNumber, number, datePayment, amountCredit, amountRepaid, amountPayment, overduePayment
        }
    }
}

// FIXME: include PersonsCreditItem after refactoring

enum CreditType: String, Codable {
 
    case `default`
    case mortgage = "ИпКред"
    case consumer = "ПотКред"
}



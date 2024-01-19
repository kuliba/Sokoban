//
//  FastPayment.swift
//  
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

extension GetCardStatementForPeriodResponse {
    
    struct FastPayment: Codable {
        
        let opkcid: String
        let foreignName: String
        let foreignPhoneNumber: String
        let foreignBankBIC: String
        let foreignBankID: String
        let foreignBankName: String
        let documentComment: String
        let operTypeFP: String
        let tradeName: String
        let guid: String
    }
}

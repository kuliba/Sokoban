//
//  Response+FastPayment.swift
//
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

extension Response {
    
    struct FastPayment: Decodable, Equatable {
        
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
        
        init(
            opkcid: String,
            foreignName: String,
            foreignPhoneNumber: String,
            foreignBankBIC: String,
            foreignBankID: String,
            foreignBankName: String,
            documentComment: String,
            operTypeFP: String,
            tradeName: String,
            guid: String
        ) {
            self.opkcid = opkcid
            self.foreignName = foreignName
            self.foreignPhoneNumber = foreignPhoneNumber
            self.foreignBankBIC = foreignBankBIC
            self.foreignBankID = foreignBankID
            self.foreignBankName = foreignBankName
            self.documentComment = documentComment
            self.operTypeFP = operTypeFP
            self.tradeName = tradeName
            self.guid = guid
        }
    }
}

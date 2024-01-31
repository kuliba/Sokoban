//
//  ProductStatementData+FastPayment.swift
//
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

public extension ProductStatementData {
    
    struct FastPayment: Equatable {
        
        public let opkcid: String
        public let foreignName: String
        public let foreignPhoneNumber: String
        public let foreignBankBIC: String
        public let foreignBankID: String
        public let foreignBankName: String
        public let documentComment: String
        public let operTypeFP: String
        public let tradeName: String
        public let guid: String
        
        public init(
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

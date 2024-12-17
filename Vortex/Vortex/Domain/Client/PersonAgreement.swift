//
//  PersonAgreement.swift
//  ForaBank
//
//  Created by Дмитрий on 31.08.2022.
//

import Foundation

struct PersonAgreement: Decodable, Equatable {
    
    let system: System
    let type: TypeDocument
    let externalUrl: URL
    let version: String
    let date: Date
    let comment: String

    private enum CodingKeys : String, CodingKey {
        
        case system, type, externalUrl, version, date, comment
    }
    
    internal init(system: System, type: TypeDocument, externalUrl: URL, version: String, date: Date, comment: String) {
        
        self.system = system
        self.type = type
        self.externalUrl = externalUrl
        self.version = version
        self.date = date
        self.comment = comment
    }
    
    enum System: String, Decodable, Equatable, CaseIterable, Hashable, Unknownable {
        
        case sbp = "SBPay"
        case unknown
    }
    
    enum TypeDocument: String, Decodable, CaseIterable, Hashable, Unknownable {
    
        case dateProcessing = "DataProcessingAgreement"
        case sbpAgreement = "SbpAgreement"
        case termsAndConditions = "TermsAndConditions"
        case unknown
    }
}

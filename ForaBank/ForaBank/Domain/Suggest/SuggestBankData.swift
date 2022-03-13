//
//  BankData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct SuggestBankData: Codable, Equatable {
    
    let address: SuggestAddressData?
    let bic: String?
    let correspondentAccount: String?
    let name: BankName?
    let okpo: String?
    let opf: BankOpf?
    let paymentCity: String?
    let phones: String?
    let registrationNumber: String?
    let state: StateData?
    let swift: String?
}

extension SuggestBankData {
    
    struct BankName: Codable, Equatable {
        
        let full: String?
        let payment: String?
        let short: String?
    }
    
    struct BankOpf: Codable, Equatable {
        
        let full: String?
        let short: String?
        let type: String?
    }
    
    struct StateData: Codable, Equatable {

        let actualityDate: String?
        let liquidationDate: String?
        let registrationDate: String?
        let status: String?
    }
}



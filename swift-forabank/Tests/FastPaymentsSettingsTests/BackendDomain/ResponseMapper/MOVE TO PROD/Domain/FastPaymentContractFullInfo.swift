//
//  FastPaymentContractFullInfo.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

struct FastPaymentContractFullInfo: Equatable {
    
    let account: Account
    let clientInfo: ClientInfo
    let contract: Contract
    
    struct Account: Equatable {
        
        let accountID: Int
        let flagPossibAddAccount: Flag
        let maxAddAccount: Int
        let minAddAccount: Int
        let accountNumber: String
    }
    
    struct ClientInfo: Equatable {
        
        let clientID: Int
        let inn: String
        let name: String
        let nm: String
        let clientSurName: String
        let clientPatronymicName: String
        let clientName: String
        let docType: String
        let regSeries: String
        let regNumber: String
        let address: String
    }
    
    struct Contract: Equatable {
        
        let accountID: Int
        let branchID: Int
        let clientID: Int
        let flagBankDefault: Flag
        let flagClientAgreementIn: Flag
        let flagClientAgreementOut: Flag
        let fpcontractID: Int
        let phoneNumber: String
        let phoneNumberMask: String
        let branchBIC: String
    }

    enum Flag: Equatable {
        
        case yes, no, empty
    }
}

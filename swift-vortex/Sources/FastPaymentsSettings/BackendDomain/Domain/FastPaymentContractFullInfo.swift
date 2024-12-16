//
//  FastPaymentContractFullInfo.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

public struct FastPaymentContractFullInfo: Equatable {
    
    public let account: Account
    public let clientInfo: ClientInfo
    public let contract: Contract
    
    public init(
        account: Account,
        clientInfo: ClientInfo,
        contract: Contract
    ) {
        self.account = account
        self.clientInfo = clientInfo
        self.contract = contract
    }
    
    public struct Account: Equatable {
        
        public let accountID: Int
        public let flagPossibAddAccount: Flag
        public let maxAddAccount: Int
        public let minAddAccount: Int
        public let accountNumber: String
        
        public init(
            accountID: Int,
            flagPossibAddAccount: Flag,
            maxAddAccount: Int,
            minAddAccount: Int,
            accountNumber: String
        ) {
            self.accountID = accountID
            self.flagPossibAddAccount = flagPossibAddAccount
            self.maxAddAccount = maxAddAccount
            self.minAddAccount = minAddAccount
            self.accountNumber = accountNumber
        }
    }
    
    public struct ClientInfo: Equatable {
        
        public let clientID: Int
        public let inn: String
        public let name: String
        public let nm: String
        public let clientSurName: String
        public let clientPatronymicName: String
        public let clientName: String
        public let docType: String
        public let regSeries: String
        public let regNumber: String
        public let address: String
        
        public init(
            clientID: Int,
            inn: String,
            name: String,
            nm: String,
            clientSurName: String,
            clientPatronymicName: String,
            clientName: String,
            docType: String,
            regSeries: String,
            regNumber: String,
            address: String
        ) {
            self.clientID = clientID
            self.inn = inn
            self.name = name
            self.nm = nm
            self.clientSurName = clientSurName
            self.clientPatronymicName = clientPatronymicName
            self.clientName = clientName
            self.docType = docType
            self.regSeries = regSeries
            self.regNumber = regNumber
            self.address = address
        }
    }
    
    public struct Contract: Equatable {
        
        public let accountID: Int
        public let branchID: Int
        public let clientID: Int
        public let flagBankDefault: Flag
        public let flagClientAgreementIn: Flag
        public let flagClientAgreementOut: Flag
        public let fpcontractID: Int
        public let phoneNumber: String
        public let phoneNumberMask: String
        public let branchBIC: String
        
        public init(
            accountID: Int,
            branchID: Int,
            clientID: Int,
            flagBankDefault: Flag,
            flagClientAgreementIn: Flag,
            flagClientAgreementOut: Flag,
            fpcontractID: Int,
            phoneNumber: String,
            phoneNumberMask: String,
            branchBIC: String
        ) {
            self.accountID = accountID
            self.branchID = branchID
            self.clientID = clientID
            self.flagBankDefault = flagBankDefault
            self.flagClientAgreementIn = flagClientAgreementIn
            self.flagClientAgreementOut = flagClientAgreementOut
            self.fpcontractID = fpcontractID
            self.phoneNumber = phoneNumber
            self.phoneNumberMask = phoneNumberMask
            self.branchBIC = branchBIC
        }
    }
    
    public enum Flag: Equatable {
        
        case yes, no, empty
    }
}

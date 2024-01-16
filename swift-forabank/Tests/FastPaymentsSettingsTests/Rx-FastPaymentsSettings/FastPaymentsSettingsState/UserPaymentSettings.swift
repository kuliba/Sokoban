//
//  UserPaymentSettings.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Tagged

public enum UserPaymentSettings: Equatable {
    
    case contracted(ContractDetails)
    case missingContract(ConsentResult)
    case failure(Failure)
}

public extension UserPaymentSettings {
    
    struct ContractDetails: Equatable {
        
        public var paymentContract: PaymentContract
        public let consentResult: ConsentResult
        public var bankDefault: BankDefault
        
        public init(
            paymentContract: PaymentContract,
            consentResult: ConsentResult,
            bankDefault: BankDefault
        ) {
            self.paymentContract = paymentContract
            self.consentResult = consentResult
            self.bankDefault = bankDefault
        }
    }
    
    struct PaymentContract: Equatable, Identifiable {

        public let id: ContractID
        public let contractStatus: ContractStatus
        
        public init(
            id: ContractID, 
            contractStatus: ContractStatus
        ) {
            self.id = id
            self.contractStatus = contractStatus
        }
        
        public typealias ContractID = Tagged<_ContractID, Int>
        public enum _ContractID {}
        
        public enum ContractStatus: Equatable {
            
            case active, inactive
        }
    }
    
    typealias ConsentResult = Result<ConsentList, ConsentError>
    
    struct ConsentList: Equatable {
        
        public init() {}
    }
    
    struct ConsentError: Error, Equatable {
        
        public init() {}
    }
    
    enum BankDefault: Equatable {
        
        case onDisabled
        case offEnabled
        case offDisabled
    }
    
    enum Failure: Equatable {
        
        case serverError(String)
        case connectivityError
    }
}

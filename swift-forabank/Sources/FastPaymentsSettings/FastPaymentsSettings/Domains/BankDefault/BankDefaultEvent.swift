//
//  BankDefaultEvent.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

public enum BankDefaultEvent: Equatable {
    
    case prepareSetBankDefault
    case setBankDefault
    case setBankDefaultResult(SetBankDefaultResult)
}

public extension BankDefaultEvent {
    
    enum SetBankDefaultResult: Equatable {
        
        case success
        case incorrectOTP(String)
        case serviceFailure(ServiceFailure)
    }
}

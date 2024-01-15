//
//  FastPaymentsSettingsState.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

public struct FastPaymentsSettingsState: Equatable {
    
    public var userPaymentSettings: UserPaymentSettings?
    public var status: Status?
    
    public init(
        userPaymentSettings: UserPaymentSettings? = nil, 
        status: Status? = nil
    ) {
        self.userPaymentSettings = userPaymentSettings
        self.status = status
    }
}

public extension FastPaymentsSettingsState {
    
    enum Status: Equatable {
        
        case inflight
        case serverError(String)
        case connectivityError
        case missingProduct
        case updateContractFailure
        case setBankDefault
        case confirmSetBankDefault//(phoneNumberMask) from contract details
    }
}

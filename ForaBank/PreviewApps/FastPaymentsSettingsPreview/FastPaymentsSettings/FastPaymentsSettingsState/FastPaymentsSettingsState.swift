//
//  FastPaymentsSettingsState.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

struct FastPaymentsSettingsState {
    
#warning("combine inflight, informer, alert into one field?")
    var isInflight = false
    var userPaymentSettings: UserPaymentSettings?
    var status: Status?
    
    enum Status {
        
        case serverError(String)
        case connectivityError
        case missingProduct
        case updateContractFailure
        case setBankDefault
        case confirmSetBankDefault//(phoneNumberMask) from contract details
    }
}

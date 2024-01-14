//
//  FastPaymentsSettingsState.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

struct FastPaymentsSettingsState: Equatable {
    
    var userPaymentSettings: UserPaymentSettings?
    var status: Status?
    
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

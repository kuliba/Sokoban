//
//  FastPaymentsSettingsState.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

import C2BSubscriptionUI

public struct FastPaymentsSettingsState: Equatable {
    
    public var settingsResult: UserPaymentSettingsResult?
    public var status: Status?
    
    public init(
        settingsResult: UserPaymentSettingsResult? = nil,
        status: Status? = nil
    ) {
        self.settingsResult = settingsResult
        self.status = status
    }
}

public extension FastPaymentsSettingsState {
    
    init(
        settingsResult: UserPaymentSettings,
        status: Status? = nil
    ) {
        self.settingsResult = .success(settingsResult)
        self.status = status
    }
}

public extension FastPaymentsSettingsState {
    #warning("split to informer/error?")
    enum Status: Equatable {
        
        case inflight
        case serverError(String)
        case connectivityError
        case missingProduct
        case updateContractFailure
        case setBankDefault
        case setBankDefaultFailure(String)
        case setBankDefaultSuccess
        case confirmSetBankDefault//(phoneNumberMask) from contract details
        case getC2BSubResponse(GetC2BSubResponse)
    }
}

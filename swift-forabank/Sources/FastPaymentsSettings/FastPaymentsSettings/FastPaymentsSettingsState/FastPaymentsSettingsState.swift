//
//  FastPaymentsSettingsState.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

public struct FastPaymentsSettingsState: Equatable {
    
    public var userPaymentSettings: UserPaymentSettingsResult?
    public var status: Status?
    
    public init(
        userPaymentSettings: UserPaymentSettingsResult? = nil,
        status: Status? = nil
    ) {
        self.userPaymentSettings = userPaymentSettings
        self.status = status
    }
}

public extension FastPaymentsSettingsState {
    
    init(
        userPaymentSettings: UserPaymentSettings,
        status: Status? = nil
    ) {
        self.userPaymentSettings = .success(userPaymentSettings)
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
        case setBankDefaultSuccess
        case confirmSetBankDefault//(phoneNumberMask) from contract details
        case getC2BSubResponse(GetC2BSubResponse)
    }
}

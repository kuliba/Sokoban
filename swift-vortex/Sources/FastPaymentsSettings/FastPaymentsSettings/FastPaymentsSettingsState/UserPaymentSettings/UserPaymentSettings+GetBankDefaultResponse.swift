//
//  UserPaymentSettings+GetBankDefaultResponse.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension UserPaymentSettings {
    
    struct GetBankDefaultResponse: Equatable {
        
        public var bankDefault: BankDefault
        public var requestLimitMessage: String?
        
        public init(
            bankDefault: BankDefault,
            requestLimitMessage: String? = nil
        ) {
            self.bankDefault = bankDefault
            self.requestLimitMessage = requestLimitMessage
        }
    }
}

public extension UserPaymentSettings.GetBankDefaultResponse {
    
    enum BankDefault: Equatable {
        
        case onDisabled
        case offEnabled
        case offDisabled
    }
}

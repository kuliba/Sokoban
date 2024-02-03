//
//  NanoServices+makeDecoratedGetBankDefault.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings

extension NanoServices {
    
    typealias BankDefaultCacheRead = () -> BankDefault?
    typealias BankDefaultCacheWrite = (BankDefault) -> Void
    
    static func makeDecoratedGetBankDefault(
        _ httpClient: HTTPClient,
        bankDefaultCacheRead: @escaping BankDefaultCacheRead,
        bankDefaultCacheWrite: @escaping BankDefaultCacheWrite,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> MicroServices.Facade.GetBankDefaultResponse {
        
        let getBankDefault = makeFPSGetBankDefault(httpClient: httpClient, log: log)
        
#warning("add cache decorator")
        let decoratedGetBankDefault: MicroServices.Facade.GetBankDefaultResponse = { payload, completion in
            
            getBankDefault(payload) { result in
                
                switch result {
                case let .failure(failure):
                    let cached = bankDefaultCacheRead()
                    let bankDefault: UserPaymentSettings.GetBankDefaultResponse.BankDefault = {
                        guard let cached else { return .offDisabled }
                        
                        return cached.settingsBankDefault
                    }()
                    
                    completion(.init(
                        bankDefault: bankDefault,
                        requestLimitMessage: failure.requestLimitMessage
                    ))
                    
                case let .success(bankDefault):
                    bankDefaultCacheWrite(bankDefault)
                    completion(.init(
                        bankDefault: bankDefault.settingsBankDefault
                    ))
                }
            }
        }
        
        return decoratedGetBankDefault
    }
}

// MARK: - Adapters

#warning("remove if unused")
private extension BankDefault {
    
    var settingsBankDefault: UserPaymentSettings.GetBankDefaultResponse.BankDefault {
        
        rawValue ? .onDisabled : .offEnabled
    }
}

private extension ServiceFailure {
    
    var requestLimitMessage: String? {
        
        let errorMessage = "Исчерпан лимит запросов. Повторите попытку через 24 часа."
        
        switch self {
        case .serverError(errorMessage):
            return errorMessage
            
        default:
            return nil
        }
    }
}

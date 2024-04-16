//
//  NanoServices+makeDecoratedGetBankDefault.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import RemoteServices

extension NanoServices {
    
    typealias BankDefaultCacheRead = () -> BankDefault?
    typealias BankDefaultCacheWrite = (BankDefault) -> Void
    
    static func makeDecoratedGetBankDefault(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> MicroServices.Facade.GetBankDefaultResponse {
        
        let bankDefaultStore = BankDefaultStore(keyTag: .bankDefault)
        
        let bankDefaultCacheRead: BankDefaultCacheRead = {
            
            guard let (bankDefault, _) = try? bankDefaultStore.load()
            else { return nil }
            
            return .init(bankDefault)
        }
        let bankDefaultCacheWrite: BankDefaultCacheWrite = {
            
            try? bankDefaultStore.save(($0.rawValue, .distantFuture))
        }
        
        let getBankDefault = adaptedLoggingFetch(
            createRequest: ForaBank.RequestFactory.createGetBankDefaultRequest,
            httpClient: httpClient,
            mapResponse: RemoteServices.ResponseMapper.mapGetBankDefaultResponse,
            mapError: ServiceFailure.init(error:),
            log: log
        )
        
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
                
                _ = getBankDefault
            }
            
            _ = getBankDefault
        }
        
        return decoratedGetBankDefault
    }
}

// MARK: - Adapters

private extension BankDefault {
    
    var settingsBankDefault: UserPaymentSettings.GetBankDefaultResponse.BankDefault {
        
        rawValue ? .onDisabled : .offEnabled
    }
}

private extension ServiceFailure {
    
    var requestLimitMessage: String? {
        
        let errorMessage = "Исчерпан лимит запросов. Повторите попытку через 24 часа."
        
        guard case .serverError(errorMessage) = self
        else { return nil }
        
        return errorMessage
    }
}

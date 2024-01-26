//
//  MicroServices+GetSettings.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

import Tagged

public extension MicroServices {
    
    final class GetSettings<Contract, Consent, Settings> {
        
        private let getContract: GetContract
        private let getConsent: GetConsent
#warning("getBankDefault should be decorated with caching!")
        private let getBankDefault: GetBankDefault
        private let mapToMissing: MapToMissing
        private let mapToSettings: MapToSettings
        
        public init(
            getContract: @escaping GetContract,
            getConsent: @escaping GetConsent,
            getBankDefault: @escaping GetBankDefault,
            mapToMissing: @escaping MapToMissing,
            mapToSettings: @escaping MapToSettings
        ) {
            self.getContract = getContract
            self.getConsent = getConsent
            self.getBankDefault = getBankDefault
            self.mapToMissing = mapToMissing
            self.mapToSettings = mapToSettings
        }
    }
}

public extension MicroServices.GetSettings {
    
    func process(
        _ phoneNumber: PhoneNumber,
        completion: @escaping Completion
    ) {
        getContract { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(failure):
                completion(.failure(failure))
                
                // missing contract
            case .success(.none):
                process(completion)
                
#warning("add tests")
            case let .success(.some(contract)):
                process(contract, phoneNumber, completion)
            }
        }
    }
}

public extension MicroServices.GetSettings {
    
    typealias SettingsResult = Result<Settings, ServiceFailure>
    typealias Completion = (SettingsResult) -> Void
}

public extension MicroServices.GetSettings {
    
    typealias GetContractResult = Result<Contract?, ServiceFailure>
    typealias GetContractCompletion = (GetContractResult) -> Void
    typealias GetContract = (@escaping GetContractCompletion) -> Void
}

public extension MicroServices.GetSettings {
    
    typealias GetConsentCompletion = (Consent) -> Void
    typealias GetConsent = (@escaping GetConsentCompletion) -> Void
}

public extension MicroServices.GetSettings {
    
    typealias PhoneNumber = Tagged<_PhoneNumber, String>
    enum _PhoneNumber {}
    
    typealias GetBankDefaultCompletion = (UserPaymentSettings.GetBankDefaultResponse) -> Void
    typealias GetBankDefault = (PhoneNumber, @escaping GetBankDefaultCompletion) -> Void
}

public typealias BankDefault = Tagged<_BankDefault, Bool>
public enum _BankDefault {}

public extension MicroServices.GetSettings {
    
    typealias MapToMissing = (Consent) -> SettingsResult
    typealias MapToSettings = (Contract, Consent, UserPaymentSettings.GetBankDefaultResponse) -> Settings
}

private extension MicroServices.GetSettings {
    
    func process(
        _ completion: @escaping Completion
    ) {
        getConsent { [weak self] resultB in
            
            guard let self else { return }
            
            completion(self.mapToMissing(resultB))
        }
    }
    
#warning("add tests")
    func process(
        _ contract: Contract,
        _ phoneNumber: PhoneNumber,
        _ completion: @escaping Completion
    ) {
        getConsent { [weak self] resultB in
            
            guard let self else { return }
            
            getBankDefault(phoneNumber) { [weak self] resultC in
                
                guard let self else { return }
                
                completion(.success(mapToSettings(contract, resultB, resultC)))
            }
        }
    }
}


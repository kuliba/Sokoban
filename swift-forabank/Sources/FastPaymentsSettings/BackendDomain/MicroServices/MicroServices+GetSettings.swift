//
//  MicroServices+GetSettings.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

import Tagged

public protocol PhoneNumbered {
    
    var phoneNumber: PhoneNumber { get }
}

public extension MicroServices {
    
    final class SettingsGetter<Contract: PhoneNumbered, Consent, Settings> {
        
        private let getContract: GetContract
        private let getConsent: GetConsent
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

public extension MicroServices.SettingsGetter {
    
    func process(
        completion: @escaping ProcessCompletion
    ) {
        getContract(completion)
    }
}

public extension MicroServices.SettingsGetter {
    
    typealias ProcessResult = Result<Settings, ServiceFailure>
    typealias ProcessCompletion = (ProcessResult) -> Void
    
    // fastPaymentContractFindList
    typealias GetContractResult = Result<Contract?, ServiceFailure>
    typealias GetContractCompletion = (GetContractResult) -> Void
    typealias GetContract = (@escaping GetContractCompletion) -> Void
    
    // getClientConsentMe2MePull
    typealias GetConsentCompletion = (Consent) -> Void
    typealias GetConsent = (@escaping GetConsentCompletion) -> Void
    
    // getBankDefault
    typealias GetBankDefaultCompletion = (UserPaymentSettings.GetBankDefaultResponse) -> Void
    typealias GetBankDefault = (PhoneNumber, @escaping GetBankDefaultCompletion) -> Void
    
    typealias MapToMissing = (Consent) -> ProcessResult
    typealias MapToSettings = (Contract, Consent, UserPaymentSettings.GetBankDefaultResponse) -> Settings
}

private extension MicroServices.SettingsGetter {
    
    func getContract(
        _ completion: @escaping ProcessCompletion
    ) {
        getContract { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(failure):
                completion(.failure(failure))
                
                // missing contract
            case .success(.none):
                processGetConsent(completion)
                
            case let .success(.some(contract)):
                process(contract, completion)
            }
        }
    }
    
    func processGetConsent(
        _ completion: @escaping ProcessCompletion
    ) {
        getConsent { [weak self] resultB in
            
            guard let self else { return }
            
            completion(self.mapToMissing(resultB))
        }
    }
    
#warning("add tests")
    func process(
        _ contract: Contract,
        _ completion: @escaping ProcessCompletion
    ) {
        getConsent { [weak self] resultB in
            
            guard let self else { return }
            
            getBankDefault(contract.phoneNumber) { [weak self] resultC in
                
                guard let self else { return }
                
                completion(.success(mapToSettings(contract, resultB, resultC)))
            }
        }
    }
}

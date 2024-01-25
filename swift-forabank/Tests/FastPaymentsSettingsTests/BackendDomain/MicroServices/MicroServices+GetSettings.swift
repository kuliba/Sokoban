//
//  MicroServices+GetSettings.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

import Tagged

public extension MicroServices {
    
    final class GetSettings<Contract, GetClientConsentMe2MePullResponse, Settings> {
        
        private let fastPaymentContractFindList: FastPaymentContractFindList
        private let getClientConsentMe2MePull: GetClientConsentMe2MePull
#warning("getBankDefault should be decorated with caching!")
        private let getBankDefault: GetBankDefault
        private let mapToMissing: MapToMissing
        private let mapToContracted: MapToContracted
        
        init(
            fastPaymentContractFindList: @escaping FastPaymentContractFindList,
            getClientConsentMe2MePull: @escaping GetClientConsentMe2MePull,
            getBankDefault: @escaping GetBankDefault,
            mapToMissing: @escaping MapToMissing,
            mapToContracted: @escaping MapToContracted
        ) {
            self.fastPaymentContractFindList = fastPaymentContractFindList
            self.getClientConsentMe2MePull = getClientConsentMe2MePull
            self.getBankDefault = getBankDefault
            self.mapToMissing = mapToMissing
            self.mapToContracted = mapToContracted
        }
    }
}

public extension MicroServices.GetSettings {
    
    func process(
        _ phoneNumber: PhoneNumber,
        completion: @escaping Completion
    ) {
        fastPaymentContractFindList { [weak self] resultA in
            
            guard let self else { return }
            
            switch resultA {
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
    
    typealias ServiceFailure = MicroServices.ServiceFailure
    
    typealias SettingsResult = Result<Settings, ServiceFailure>
    typealias Completion = (SettingsResult) -> Void
}

public extension MicroServices.GetSettings {
    
    typealias FastPaymentContractFindListResult = Result<Contract?, ServiceFailure>
    typealias FastPaymentContractFindListCompletion = (FastPaymentContractFindListResult) -> Void
    typealias FastPaymentContractFindList = (@escaping FastPaymentContractFindListCompletion) -> Void
}

public extension MicroServices.GetSettings {
    
    typealias GetClientConsentMe2MePullResult = Result<GetClientConsentMe2MePullResponse, ServiceFailure>
    typealias GetClientConsentMe2MePullCompletion = (GetClientConsentMe2MePullResult) -> Void
    typealias GetClientConsentMe2MePull = (@escaping GetClientConsentMe2MePullCompletion) -> Void
}

public extension MicroServices.GetSettings {
    
    typealias PhoneNumber = Tagged<_PhoneNumber, String>
    enum _PhoneNumber {}
    
    typealias BankDefault = Tagged<_BankDefault, Bool>
    enum _BankDefault {}
    
    typealias GetBankDefaultResult = Result<BankDefault, GetBankDefaultFailure>
    typealias GetBankDefaultCompletion = (GetBankDefaultResult) -> Void
    typealias GetBankDefault = (PhoneNumber, @escaping GetBankDefaultCompletion) -> Void
    
    enum GetBankDefaultFailure: Error, Equatable {
        
        case failure(ServiceFailure)
        case limit
    }
}

public extension MicroServices.GetSettings {
    
    typealias MapToMissing = (GetClientConsentMe2MePullResult) -> SettingsResult
    typealias MapToContracted = (Contract, GetClientConsentMe2MePullResult, GetBankDefaultResult) -> SettingsResult
}

private extension MicroServices.GetSettings {
    
    func process(
        _ completion: @escaping Completion
    ) {
        getClientConsentMe2MePull { [weak self] resultB in
            
            guard let self else { return }
            
            completion(self.mapToMissing(resultB))
        }
    }
    
    func process(
        _ contract: Contract,
        _ phoneNumber: PhoneNumber,
        _ completion: @escaping Completion
    ) {
        getClientConsentMe2MePull { [weak self] resultB in
            
            guard let self else { return }
            
            getBankDefault(phoneNumber) { [weak self] resultC in
                
                guard let self else { return }
                
                completion(mapToContracted(contract, resultB, resultC))
            }
        }
    }
}

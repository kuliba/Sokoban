//
//  MicroServices+Facade.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

import Tagged

public extension MicroServices {
    
    final class Facade {
        
        private let createFastContract: CreateFastContract
        private let getBankDefaultResponse: GetBankDefaultResponse
        private let getClientConsent: GetClientConsent
        private let getFastContract: GetFastContract
        private let getProducts: GetProducts
        private let getBanks: GetBanks
        private let updateFastContract: UpdateFastContract
        
        public init(
            createFastContract: @escaping CreateFastContract,
            getBankDefaultResponse: @escaping GetBankDefaultResponse,
            getClientConsent: @escaping GetClientConsent,
            getFastContract: @escaping GetFastContract,
            getProducts: @escaping GetProducts,
            getBanks: @escaping GetBanks,
            updateFastContract: @escaping UpdateFastContract
        ) {
            self.createFastContract = createFastContract
            self.getBankDefaultResponse = getBankDefaultResponse
            self.getClientConsent = getClientConsent
            self.getFastContract = getFastContract
            self.getProducts = getProducts
            self.getBanks = getBanks
            self.updateFastContract = updateFastContract
        }
    }
}

extension UserPaymentSettings.PaymentContract: PhoneNumbered {}

public extension MicroServices.Facade {
    
    typealias SettingsGetter = MicroServices.SettingsGetter<Contract, Consent?, UserPaymentSettings>
    typealias GetSettings = (@escaping SettingsGetter.ProcessCompletion) -> Void
    
    /// `abc` flow
    func getSettings() -> GetSettings {
        
        let settingsGetter = SettingsGetter(
            getContract: getFastContract,
            getConsent: getClientConsent,
            getBankDefault: getBankDefaultResponse,
            getProducts: getProducts,
            getBanks: getBanks
        )
        
        return settingsGetter.process(completion:)
    }
}

extension UserPaymentSettings.PaymentContract: StatusReporting {
    
    /// `da` flow
    public var status: ContractStatus {
        
        switch contractStatus {
        case .active:   return .active
        case .inactive: return .inactive
        }
    }
}

public extension MicroServices.Facade {
    
    typealias ContractUpdater = MicroServices.ContractUpdater<Contract.ID, Product.ID, Contract>
    
    func makeContractUpdater() -> ContractUpdater {
        
        .init(
            getContract: getFastContract,
            updateContract: updateFastContract
        )
    }
}

public extension MicroServices.Facade {
    
    typealias ContractMaker = MicroServices.ContractMaker<Product.ID, Contract>
    
    func makeContractMaker() -> ContractMaker {
        
        .init(
            createContract: createFastContract,
            getContract: getFastContract
        )
    }
}

public extension MicroServices.Facade {
    
    typealias Contract = UserPaymentSettings.PaymentContract
    
    // createFastPaymentContract
    typealias CreateFastContractPayload = Product.ID
    typealias CreateFastContractResponse = Result<Void, ServiceFailure>
    typealias CreateFastContractCompletion = (CreateFastContractResponse) -> Void
    typealias CreateFastContract = (CreateFastContractPayload, @escaping CreateFastContractCompletion) -> Void
    
    // getBankDefault
    typealias GetBankDefaultCompletion = (UserPaymentSettings.GetBankDefaultResponse) -> Void
    typealias GetBankDefaultResponse = (PhoneNumber, @escaping GetBankDefaultCompletion) -> Void
    
    // getClientConsentMe2MePull
    typealias GetClientConsentCompletion = (Consent?) -> Void
    typealias GetClientConsent = (@escaping GetClientConsentCompletion) -> Void
    
    // fastPaymentContractFindList
    typealias GetFastContractResult = Result<Contract?, ServiceFailure>
    typealias GetFastContractCompletion = (GetFastContractResult) -> Void
    typealias GetFastContract = (@escaping GetFastContractCompletion) -> Void
    
    typealias GetProducts = () -> [Product]
    typealias GetBanks = () -> [Bank]
    
    // updateFastPaymentContract
    typealias ContractUpdatePayload = ContractUpdater.Payload
    typealias UpdateFastContractResponse = Result<Void, ServiceFailure>
    typealias UpdateFastContractCompletion = (UpdateFastContractResponse) -> Void
    typealias UpdateFastContract = (ContractUpdatePayload, @escaping UpdateFastContractCompletion) -> Void
}

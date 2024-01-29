//
//  MicroServices+Factory.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

extension MicroServices {
    
    final class Factory {
        
        private let createContract: CreateContract
#warning("getBankDefault should be decorated with caching!")
        private let getBankDefault: GetBankDefault
        private let getConsent: GetConsent
        private let getContract: GetContract
        private let getProducts: GetProducts
        private let updateContract: UpdateContract
        
        init(
            createContract: @escaping CreateContract,
            getBankDefault: @escaping GetBankDefault,
            getConsent: @escaping GetConsent,
            getContract: @escaping GetContract,
            getProducts: @escaping GetProducts,
            updateContract: @escaping UpdateContract
        ) {
            self.createContract = createContract
            self.getBankDefault = getBankDefault
            self.getConsent = getConsent
            self.getContract = getContract
            self.getProducts = getProducts
            self.updateContract = updateContract
        }
    }
}

extension UserPaymentSettings.PaymentContract: PhoneNumbered {}

extension MicroServices.Factory {
    
    typealias GetSettings = MicroServices.GetSettings<Contract, Consent, UserPaymentSettings>
    
    /// `abc` flow
    func makeGetSettings() -> GetSettings {
        
        .init(
            getContract: getContract,
            getConsent: getConsent,
            getBankDefault: getBankDefault,
            getProducts: getProducts
        )
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

extension MicroServices.Factory {
    
    typealias ContractUpdater = MicroServices.ContractUpdater<Contract.ID, Product.ID, Contract>
    
    func makeContractUpdater() -> ContractUpdater {
        
        .init(
            getContract: getContract,
            updateContract: updateContract
        )
    }
}

extension MicroServices.Factory {
    
    typealias ContractMaker = MicroServices.ContractMaker<Product.ID, Contract>
    
    func makeContractMaker() -> ContractMaker {
        
        .init(
            createContract: createContract,
            getContract: getContract
        )
    }
}

extension MicroServices.Factory {
    
    typealias Contract = UserPaymentSettings.PaymentContract
    typealias Consent = ConsentListState
    
    // createFastPaymentContract
    typealias CreateContractPayload = Product.ID
    typealias CreateContractResponse = Result<Void, ServiceFailure>
    typealias CreateContractCompletion = (CreateContractResponse) -> Void
    typealias CreateContract = (CreateContractPayload, @escaping CreateContractCompletion) -> Void
    
    // getBankDefault
    typealias GetBankDefaultCompletion = (UserPaymentSettings.GetBankDefaultResponse) -> Void
    typealias GetBankDefault = (PhoneNumber, @escaping GetBankDefaultCompletion) -> Void
    
    // getClientConsentMe2MePull
    typealias GetConsentCompletion = (Consent) -> Void
    typealias GetConsent = (@escaping GetConsentCompletion) -> Void
    
    // fastPaymentContractFindList
    typealias GetContractResult = Result<Contract?, ServiceFailure>
    typealias GetContractCompletion = (GetContractResult) -> Void
    typealias GetContract = (@escaping GetContractCompletion) -> Void
    
    typealias GetProducts = () -> [Product]
    
    // updateFastPaymentContract
    typealias ContractUpdatePayload = ContractUpdater.Payload
    typealias UpdateContractResponse = Result<Void, ServiceFailure>
    typealias UpdateContractCompletion = (UpdateContractResponse) -> Void
    typealias UpdateContract = (ContractUpdatePayload, @escaping UpdateContractCompletion) -> Void
}

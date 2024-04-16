//
//  MicroServices.Facade+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings
import Fetcher
import GenericRemoteService

extension MicroServices.Facade {
    
    typealias NanoFetch<Payload, Success> = NanoServices.Fetch<Payload, Success, ServiceFailure>
    typealias NanoVoidFetch<Success> = NanoServices.VoidFetch<Success, ServiceFailure>
    
    typealias NanoFetcher<Payload, Success> = Fetcher<Payload, Success, ServiceFailure>
    
    typealias CreateFastContractFetch = NanoFetch<CreateFastContractPayload, Void>
    typealias GetClientConsentFetch = NanoVoidFetch<[ConsentMe2MePull]>
    typealias GetFastContractFetch = NanoVoidFetch<FastPaymentContractFullInfo?>
    typealias UpdateFastContractFetch = NanoFetch<ContractUpdatePayload, Void>
    
    convenience init(
        createFastContractFetch: @escaping CreateFastContractFetch,
        getBankDefaultResponse: @escaping GetBankDefaultResponse,
        getClientConsentFetch: @escaping GetClientConsentFetch,
        getFastContractFetch: @escaping GetFastContractFetch,
        getProducts: @escaping GetProducts,
        getBanks: @escaping GetBanks,
        updateFastContractFetch: @escaping UpdateFastContractFetch
    ) {
        let getClientConsent: GetClientConsent = { completion in
            
            getClientConsentFetch { completion(.init(result: $0)) }
        }
            
        let getFastContract: GetFastContract = { completion in
            
            getFastContractFetch { completion(.init(result: $0)) }
        }
        
        self.init(
            createFastContract: createFastContractFetch,
            getBankDefaultResponse: getBankDefaultResponse,
            getClientConsent: getClientConsent,
            getFastContract: getFastContract,
            getProducts: getProducts,
            getBanks: getBanks,
            updateFastContract: updateFastContractFetch
        )
    }
}

// MARK: - Adapters
#warning("add tests; find a way to move into mapper")
extension Consent {
    
    init?(result: Result<[ConsentMe2MePull], ServiceFailure>) {
        
        switch result {
        case .failure:
            return nil
            
        case let .success(consents):
            self = .init(consents.map(\.bankID).map { .init(rawValue: $0)} )
        }
    }
}

private extension Result<UserPaymentSettings.PaymentContract?, ServiceFailure> {
    
    init(result: Result<FastPaymentContractFullInfo?, ServiceFailure>) {
        
        switch result {
        case let .failure(failure):
            self = .failure(failure)
            
        case .success(.none):
            self = .success(.none)
            
        case let .success(.some(info)):
            self = .success(.init(info: info))
        }
    }
}

private extension UserPaymentSettings.PaymentContract {
    
    init?(info: FastPaymentContractFullInfo) {
        
        guard let contractStatus = info.contractStatus else { return nil }
        
        self.init(
            id: .init(info.contract.fpcontractID),
            accountID: .init(info.account.accountID),
            contractStatus: contractStatus,
            phoneNumber: .init(info.contract.phoneNumber),
            phoneNumberMasked: .init(info.contract.phoneNumberMask)
        )
    }
}

private extension FastPaymentContractFullInfo {
    
    var contractStatus: ContractStatus? {
        
        if hasTripleYes { return .active }
        if hasTripleNo { return .inactive }
        
        return nil
    }
    
    private var hasTripleYes: Bool {
        
        account.flagPossibAddAccount == .yes
        && contract.flagClientAgreementIn == .yes
        && contract.flagClientAgreementOut == .yes
    }
    
    private var hasTripleNo: Bool {
        
        account.flagPossibAddAccount == .no
        && contract.flagClientAgreementIn == .no
        && contract.flagClientAgreementOut == .no
    }
}

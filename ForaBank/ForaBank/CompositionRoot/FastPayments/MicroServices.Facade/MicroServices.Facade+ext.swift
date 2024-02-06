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
    
    typealias NanoFetch<Payload, Success> = NanoServices.Fetch<Payload, Success>
    typealias NanoVoidFetch<Success> = NanoServices.VoidFetch<Success>
    
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
            self = .failure(.connectivityError)
            
        case let .success(.some(info)):
            self = .success(.init(info: info))
        }
    }
}

private extension UserPaymentSettings.PaymentContract {
    
    init?(info: FastPaymentContractFullInfo) {
        
        guard let contractStatus = UserPaymentSettings.PaymentContract.ContractStatus(info: info)
        else { return nil }
        
        self.init(
            id: .init(info.contract.fpcontractID),
            productID: .init(info.account.accountID),
            contractStatus: contractStatus,
            phoneNumber: .init(info.contract.phoneNumber),
            phoneNumberMasked: info.contract.phoneNumberMask
        )
    }
}

private extension UserPaymentSettings.PaymentContract.ContractStatus {
    
    init?(info: FastPaymentContractFullInfo) {
        
        if info.hasTripleYes { self = .active }
        if info.hasTripleNo { self = .inactive }
        
        return nil
    }
}

private extension FastPaymentContractFullInfo {
    
    var hasTripleYes: Bool {
        
        account.flagPossibAddAccount == .yes
        && contract.flagClientAgreementIn == .yes
        && contract.flagClientAgreementOut == .yes
    }
    
    var hasTripleNo: Bool {
        
        account.flagPossibAddAccount == .no
        && contract.flagClientAgreementIn == .no
        && contract.flagClientAgreementOut == .no
    }
}

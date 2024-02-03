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
    
    typealias NanoFetcher<Payload, Success> = Fetcher<Payload, Success, ServiceFailure>
    
    typealias CreateFastContractFetcher = any NanoFetcher<CreateFastContractPayload, Void>
    typealias GetClientConsentFetcher = any NanoFetcher<Void, [ConsentMe2MePull]>
    typealias GetFastContractFetcher = any NanoFetcher<Void, FastPaymentContractFullInfo?>
    typealias UpdateFastContractFetcher = any NanoFetcher<ContractUpdatePayload, Void>
    
    convenience init(
        createFastContractFetcher: CreateFastContractFetcher,
        getBankDefaultResponse: @escaping GetBankDefaultResponse,
        getClientConsentFetcher: GetClientConsentFetcher,
        getFastContractFetcher: GetFastContractFetcher,
        getProducts: @escaping GetProducts,
        getBanks: @escaping GetBanks,
        updateFastContractFetcher: UpdateFastContractFetcher
    ) {
        let getClientConsent: GetClientConsent = { completion in
            
            getClientConsentFetcher.fetch { completion(.init(result: $0)) }
        }
            
        let getFastContract: GetFastContract = { completion in
            
            getFastContractFetcher.fetch { completion(.init(result: $0)) }
        }
        
        self.init(
            createFastContract: createFastContractFetcher.fetch,
            getBankDefaultResponse: getBankDefaultResponse,
            getClientConsent: getClientConsent,
            getFastContract: getFastContract,
            getProducts: getProducts,
            getBanks: getBanks,
            updateFastContract: updateFastContractFetcher.fetch
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

//
//  NanoServices+makeFPSGetContract.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Fetcher
import Foundation
import GenericRemoteService

extension NanoServices {
    
    static func makeFPSGetContract(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> MicroServices.Facade.GetFastContract {
        
        let fastPaymentContractFindListService = loggingRemoteService(
            createRequest: ForaBank.RequestFactory.createFastPaymentContractFindListRequest,
            httpClient: httpClient,
            mapResponse: FastPaymentsSettings.ResponseMapper.mapFastPaymentContractFindListResponse,
            log: log
        )
        
        let adaptedFastPaymentContractFindListService = FetchAdapter(
            fetch: fastPaymentContractFindListService.fetch(_:completion:),
            mapResult: MicroServices.Facade.GetFastContractResult.init(result:)
        )
        
        return adaptedFastPaymentContractFindListService.fetch(completion:)
    }
}

// MARK: - Adapters

private extension Result<UserPaymentSettings.PaymentContract?, ServiceFailure> {
    
    init(result: Result<FastPaymentContractFullInfo?, RemoteServiceError<Error, Error, MappingError>>) {
        #warning("reuse init from NanoServices+makeFPSGetBankDefault.swift:49")
        switch result {
        case let .failure(failure):
            switch failure {
            case .createRequest, .performRequest:
                self = .failure(.connectivityError)
                
            case let .mapResponse(mapResponseError):
                switch mapResponseError {
                case .invalid:
                    self = .failure(.connectivityError)
                    
                case let .server(_, errorMessage):
                    self = .failure(.serverError(errorMessage))
                }
            }
            
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

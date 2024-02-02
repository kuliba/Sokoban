//
//  NanoServices+makeFPSUpdateContract.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Fetcher
import Foundation
import GenericRemoteService

extension NanoServices {
    
    static func makeFPSUpdateContract(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> MicroServices.Facade.UpdateContract {
        
        let updateFastPaymentContractService = loggingRemoteService(
            createRequest: ForaBank.RequestFactory.createUpdateFastPaymentContractRequest,
            httpClient: httpClient,
            mapResponse: FastPaymentsSettings.ResponseMapper.mapUpdateFastPaymentContractResponse,
            log: log
        )
        
        let adaptedUpdateFastPaymentContractService = FetchAdapter(
            fetch: updateFastPaymentContractService.fetch(_:completion:),
            mapError: ServiceFailure.init(error:)
        )

        return { payload, completion in
            
            adaptedUpdateFastPaymentContractService.fetch(
                .create(payload),
                completion: completion
            )
        }
    }
}

private extension FastPaymentsSettings.RequestFactory.UpdateFastPaymentContractPayload {
    
    static func create(
        _ payload: MicroServices.Facade.ContractUpdatePayload
    ) -> Self {
        
        switch payload.target {
        case .active:
            return .init(
                contractID: payload.contractID.rawValue,
                accountID: payload.accountID.rawValue,
                flagBankDefault: .empty,
                flagClientAgreementIn: .yes,
                flagClientAgreementOut: .yes
            )
            
        case .inactive:
            return .init(
                contractID: payload.contractID.rawValue,
                accountID: payload.accountID.rawValue,
                flagBankDefault: .empty,
                flagClientAgreementIn: .no,
                flagClientAgreementOut: .no
            )
        }
    }
}

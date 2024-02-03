//
//  NanoServices+makeFPSCreateContract.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Fetcher
import Foundation
import GenericRemoteService

extension NanoServices {
    
    static func makeFPSCreateContract(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> MicroServices.Facade.CreateContract {
        
        let createFastPaymentContractService = loggingRemoteService(
            createRequest: ForaBank.RequestFactory.createCreateFastPaymentContractRequest,
            httpClient: httpClient,
            mapResponse: FastPaymentsSettings.ResponseMapper.mapCreateFastPaymentContractResponse,
            log: log
        )
        
        let adaptedCreateFastPaymentContractService = FetchAdapter(
            fetch: createFastPaymentContractService.fetch(_:completion:),
            mapError: ServiceFailure.init(error:)
        )
        return {
            
            adaptedCreateFastPaymentContractService.fetch(
                .create($0),
                completion: $1
            )
        }
    }
}

private extension FastPaymentsSettings.RequestFactory.CreateFastPaymentContractPayload {
    
    static func create(
        _ productID: FastPaymentsSettings.Product.ID
    ) -> Self {
        
        .init(
            accountID: productID.rawValue,
            flagBankDefault: .empty,
            flagClientAgreementIn: .yes,
            flagClientAgreementOut: .yes
        )
    }
}

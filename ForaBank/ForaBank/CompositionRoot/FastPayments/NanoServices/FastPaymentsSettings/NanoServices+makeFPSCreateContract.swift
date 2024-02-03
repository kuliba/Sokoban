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
    ) -> MicroServices.Facade.CreateFastContract {
        
        let adapted = adaptedLoggingRemoteFetch(
            createRequest: ForaBank.RequestFactory.createCreateFastPaymentContractRequest,
            httpClient: httpClient,
            mapResponse: FastPaymentsSettings.ResponseMapper.mapCreateFastPaymentContractResponse,
            log: log
        )
        
        return { adapted(.create($0), $1) }
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

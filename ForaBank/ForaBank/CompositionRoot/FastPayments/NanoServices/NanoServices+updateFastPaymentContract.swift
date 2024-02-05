//
//  NanoServices+updateFastPaymentContract.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.02.2024.
//

import FastPaymentsSettings

extension NanoServices {
    
    static func updateFastPaymentContract(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> Fetch<FastRequestFactory.UpdateFastPaymentContractPayload, Void> {
        
      adaptedLoggingFetch(
            createRequest: ForaRequestFactory.createUpdateFastPaymentContractRequest,
            httpClient: httpClient,
            mapResponse: FastResponseMapper.mapUpdateFastPaymentContractResponse,
            log: log
        )
    }
}

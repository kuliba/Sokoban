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
    ) -> Fetch<FastRequestFactory.UpdateFastPaymentContractPayload, Void, ServiceFailure> {
#warning("move to the call site")
      return adaptedLoggingFetch(
            createRequest: ForaRequestFactory.createUpdateFastPaymentContractRequest,
            httpClient: httpClient,
            mapResponse: FastResponseMapper.mapUpdateFastPaymentContractResponse,
            mapError: ServiceFailure.init(error:),
            log: log
        )
    }
}

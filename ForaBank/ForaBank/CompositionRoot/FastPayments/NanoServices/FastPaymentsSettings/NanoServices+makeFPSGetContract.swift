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
    
    typealias GetContractResult = Result<FastPaymentContractFullInfo?, ServiceFailure>
    typealias GetContractCompletion = (GetContractResult) -> Void
    typealias GetContract = (@escaping GetContractCompletion) -> Void
    
    static func makeFPSGetContract(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> GetContract {
        
        adaptedLoggingRemoteFetch(
            createRequest: ForaBank.RequestFactory.createFastPaymentContractFindListRequest,
            httpClient: httpClient,
            mapResponse: FastPaymentsSettings.ResponseMapper.mapFastPaymentContractFindListResponse,
            log: log
        )
    }
}

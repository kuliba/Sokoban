//
//  NanoServices+makeGetOperationDetailByPaymentID.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.03.2024.
//

import AnywayPaymentBackend
import Fetcher
import RemoteServices

extension NanoServices {
    
    static func makeGetOperationDetailByPaymentID(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> GetOperationDetailByPaymentID {
        
        let loggingRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createGetOperationDetailByPaymentIDRequestModule,
            performRequest: httpClient.performRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetOperationDetailByPaymentIDResponse,
            log: log,
            file: file,
            line: line
        ).remoteService
        
        let nilified = NilifyDecorator(decoratee: loggingRemoteService.process(_:completion:))
        
        return nilified.process(_:_:)
    }
}

extension NanoServices {
    
    typealias GetOperationDetailByPaymentIDPayload = RemoteServices.RequestFactory.OperationDetailID
    typealias GetOperationDetailByPaymentIDResponse = RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse
    typealias GetOperationDetailByPaymentIDResult = GetOperationDetailByPaymentIDResponse?
    typealias GetOperationDetailByPaymentIDCompletion = (GetOperationDetailByPaymentIDResult) -> Void
    typealias GetOperationDetailByPaymentID = (GetOperationDetailByPaymentIDPayload, @escaping GetOperationDetailByPaymentIDCompletion) -> Void
}

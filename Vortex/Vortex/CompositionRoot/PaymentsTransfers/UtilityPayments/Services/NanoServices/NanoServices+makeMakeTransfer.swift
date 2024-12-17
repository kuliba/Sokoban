//
//  NanoServices+makeMakeTransfer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.03.2024.
//

import AnywayPaymentBackend
import Fetcher
import RemoteServices

extension NanoServices {
    
    static func makeMakeTransfer(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> MakeTransfer {
        
        let loggingRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createMakeTransferRequest,
            performRequest: httpClient.performRequest,
            mapResponse: RemoteServices.ResponseMapper.mapMakeTransferResponse,
            log: log,
            file: file,
            line: line
        ).remoteService
        
        let nilified = NilifyDecorator(decoratee: loggingRemoteService.process(_:completion:))
        
        return nilified.process(_:_:)
    }
}

extension NanoServices {
    
    typealias MakeTransferPayload = RemoteServices.RequestFactory.VerificationCode
    typealias MakeTransferResponse = RemoteServices.ResponseMapper.MakeTransferResponse
    typealias MakeTransferResult = MakeTransferResponse?
    typealias MakeTransferCompletion = (MakeTransferResult) -> Void
    typealias MakeTransfer = (MakeTransferPayload, @escaping MakeTransferCompletion) -> Void
}

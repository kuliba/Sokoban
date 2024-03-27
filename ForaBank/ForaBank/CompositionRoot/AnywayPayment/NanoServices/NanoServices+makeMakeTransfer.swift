//
//  NanoServices+makeMakeTransfer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.03.2024.
//

import AnywayPayment
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
        
        return { code, completion in
            
            loggingRemoteService.process(code) { result in
                
                completion(try? result.get())
            }
        }
    }
}

extension NanoServices {
    
    typealias MakeTransferResponse = RemoteServices.ResponseMapper.MakeTransferResponse
    typealias MakeTransferCompletion = (MakeTransferResponse?) -> Void
    typealias MakeTransfer = (RemoteServices.RequestFactory.VerificationCode, @escaping MakeTransferCompletion) -> Void
}

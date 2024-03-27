//
//  NanoServices+makeGetOperationDetailByPaymentID.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.03.2024.
//

import AnywayPayment
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
        
        return { id, completion in
            
            loggingRemoteService.process(id) { result in
                
                completion(try? result.get())
            }
        }
    }
}

extension NanoServices {
    
    typealias GetOperationDetailByPaymentIDPayload = RemoteServices.RequestFactory.OperationDetailID
    typealias GetOperationDetailByPaymentIDResponse = RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse
    typealias GetOperationDetailByPaymentIDResult = GetOperationDetailByPaymentIDResponse?
    typealias GetOperationDetailByPaymentIDCompletion = (GetOperationDetailByPaymentIDResult) -> Void
    typealias GetOperationDetailByPaymentID = (GetOperationDetailByPaymentIDPayload, @escaping GetOperationDetailByPaymentIDCompletion) -> Void
}

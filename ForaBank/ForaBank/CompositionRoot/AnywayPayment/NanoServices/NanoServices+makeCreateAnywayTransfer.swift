//
//  NanoServices+makeCreateAnywayTransfer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.03.2024.
//

import AnywayPayment
import RemoteServices
import GenericRemoteService

extension NanoServices {
    
    static func makeCreateAnywayTransferNew(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> CreateAnywayTransfer {
        
        let loggingRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createCreateAnywayTransferNewRequest,
            performRequest: httpClient.performRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateAnywayTransferResponse,
            log: log,
            file: file,
            line: line
        ).remoteService
        
        return { id, completion in
            
            loggingRemoteService.process(id) { result in
                
                completion(result.mapError(ServiceFailure.init))
            }
        }
    }
    
    static func makeCreateAnywayTransfer(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> CreateAnywayTransfer {
        
        let loggingRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createCreateAnywayTransferRequest,
            performRequest: httpClient.performRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateAnywayTransferResponse,
            log: log,
            file: file,
            line: line
        ).remoteService
        
        return { id, completion in
            
            loggingRemoteService.process(id) { result in
                
                completion(result.mapError(ServiceFailure.init))
            }
        }
    }
}

extension NanoServices {
    
    typealias CreateAnywayTransferPayload = RemoteServices.RequestFactory.CreateAnywayTransferPayload
    typealias CreateAnywayTransferResponse = RemoteServices.ResponseMapper.CreateAnywayTransferResponse
    typealias CreateAnywayTransferResult = Result<CreateAnywayTransferResponse, ServiceFailure>
    typealias CreateAnywayTransferCompletion = (CreateAnywayTransferResult) -> Void
    typealias CreateAnywayTransfer = (CreateAnywayTransferPayload, @escaping CreateAnywayTransferCompletion) -> Void
}

private extension ServiceFailure {
    
    typealias RemoteError = RemoteServiceError<Error, Error, RemoteServices.ResponseMapper.MappingError>
    
    init(_ error: RemoteError) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .connectivityError
            
        case let .mapResponse(mapResponseError):
            switch mapResponseError {
            case .invalid:
                self = .connectivityError
            case let .server(_, message):
                self = .serverError(message)
            }
        }
    }
}

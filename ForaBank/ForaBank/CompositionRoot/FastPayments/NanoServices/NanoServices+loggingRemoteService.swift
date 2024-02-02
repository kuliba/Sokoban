//
//  NanoServices+loggingRemoteService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import Foundation
import GenericRemoteService

extension NanoServices {
    
    static func loggingRemoteService<Input, Output, MapResponseError: Error>(
        createRequest: @escaping (Input) throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Output, MapResponseError>,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> RemoteService<Input, Output, Error, Error, MapResponseError> {
        
        LoggingRemoteServiceDecorator(
            createRequest: createRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: mapResponse,
            log: log
        ).remoteService
    }
}

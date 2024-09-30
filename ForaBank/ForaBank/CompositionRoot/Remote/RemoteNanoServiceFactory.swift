//
//  RemoteNanoServiceFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.09.2024.
//

import Foundation
import RemoteServices

/// A protocol for creating remote nano services.
protocol RemoteNanoServiceFactory {
    
    /// The error type used during response mapping.
    typealias MappingError = RemoteServices.ResponseMapper.MappingError
    
    /// Composes a service using request creation and response mapping.
    func compose<Payload, Response>(
        makeRequest: @escaping RemoteDomain<Payload, Response, MappingError, Error>.MakeRequest,
        mapResponse: @escaping RemoteDomain<Payload, Response, MappingError, Error>.MapResponse
    ) -> RemoteDomain<Payload, Response, MappingError, Error>.Service
}

//
//  RemoteService+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2023.
//

import GenericRemoteService
import Foundation

extension RemoteService where CreateRequestError == Error {
    
    convenience init(
        createRequest: @escaping (Input) throws -> URLRequest,
        performRequest: @escaping PerformRequest,
        mapResponse: @escaping MapResponse
    ) {
        self.init(
            createRequest: { input in .init { try createRequest(input) }},
            performRequest: performRequest,
            mapResponse: mapResponse
        )
    }
    
    convenience init(
        createRequest: @escaping () throws -> URLRequest,
        performRequest: @escaping PerformRequest,
        mapResponse: @escaping MapResponse
    ) {
        self.init(
            createRequest: { _ in .init { try createRequest() }},
            performRequest: performRequest,
            mapResponse: mapResponse
        )
    }
}

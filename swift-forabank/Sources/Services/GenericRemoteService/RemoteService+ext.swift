//
//  RemoteService+ext.swift
//  
//
//  Created by Igor Malyarov on 16.10.2023.
//

import Foundation

public extension RemoteService
where CreateRequestError == Error,
      PerformRequestError == Error,
      MapResponseError == Error {
    
    convenience init(
        createRequest: @escaping (Input) throws -> URLRequest,
        performRequest: @escaping PerformRequest,
        mapResponse: @escaping (Response) throws -> Output
    ) {
        self.init(
            createRequest: { input in .init { try createRequest(input) }},
            performRequest: performRequest,
            mapResponse: { response in .init { try mapResponse(response) }}
        )
    }
}

public typealias RemoteServiceOf<Input, Output> = RemoteService<Input, Output, Error, Error, Error>

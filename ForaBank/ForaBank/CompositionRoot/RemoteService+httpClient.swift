//
//  RemoteService+httpClient.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.09.2024.
//

import GenericRemoteService
import Foundation

extension RemoteService
where CreateRequestError == Error,
      PerformRequestError == Error,
      MapResponseError == Error {
    
    convenience init(
        createRequest: @escaping (Input) throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping ((Data, HTTPURLResponse)) -> Result<Output, Error>
    ) {
        self.init(
            createRequest: createRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: mapResponse
        )
    }
    
    convenience init(
        createRequest: @escaping () throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping ((Data, HTTPURLResponse)) -> Result<Output, Error>
    ) {
        self.init(
            createRequest: createRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: mapResponse
        )
    }
}

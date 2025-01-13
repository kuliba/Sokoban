//
//  RemoteService+Extension.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 17.11.2023.
//

import Foundation
import GenericRemoteService

extension RemoteService where CreateRequestError == Error {
    
    typealias UnTupleMapResponse = (Data, HTTPURLResponse) -> Result<Output, MapResponseError>
    
    convenience init(
        createRequest: @escaping (Input) throws -> URLRequest,
        performRequest: @escaping PerformRequest,
        mapResponse: @escaping UnTupleMapResponse
    ) {
        self.init(
            createRequest: { input in .init { try createRequest(input) }},
            performRequest: performRequest,
            mapResponse: { mapResponse($0.0, $0.1) }
        )
    }
}

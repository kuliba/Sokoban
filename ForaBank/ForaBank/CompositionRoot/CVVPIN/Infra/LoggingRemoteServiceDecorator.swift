//
//  LoggingRemoteServiceDecorator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

import Foundation
import GenericRemoteService

final class LoggingRemoteServiceDecorator<Input, Output, PerformRequestError, MapResponseError>
where PerformRequestError: Error,
      MapResponseError: Error {
    
    typealias Decoratee = RemoteService<Input, Output, Error, PerformRequestError, MapResponseError>
    typealias CreateRequest = (Input) throws -> URLRequest
    
    let remoteService: Decoratee
    
    init(
        createRequest: @escaping CreateRequest,
        performRequest: @escaping Decoratee.PerformRequest,
        mapResponse: @escaping Decoratee.MapResponse,
        log: @escaping (String) -> Void = { LoggerAgent.shared.log(level: .debug, category: .network, message: $0) }
    ) {
        self.remoteService = .init(
            createRequest: { [log] input in
                
                let request = try RequestFactory.makeGetProcessingSessionCode()
                log("RemoteService: Created request \(request) for input \(input)")
                
                return request
            },
            performRequest: performRequest,
            mapResponse: { data, httpURLResponse in
                
                log("RemoteService: Response: data: \(String(describing: String(data: data, encoding: .utf8))), status code: \(httpURLResponse.statusCode).")
                let result = mapResponse((data, httpURLResponse))
                log("RemoteService: mapResponse result: \(result).")
                
                return result
            }
        )
    }
}

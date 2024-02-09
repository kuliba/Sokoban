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
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        self.remoteService = .init(
            createRequest: { [log] input in
                
                let request = try createRequest(input)
                log("RemoteService: Created \(request.httpMethod ?? "n/a") request \(request) for input \"\(input)\".", file, line)
                if let body = request.httpBody {
                    log("RemoteService: request body: \(String(data: body, encoding: .utf8) ?? "nil")", file, line)
                }
                
                return request
            },
            performRequest: performRequest,
            mapResponse: { data, httpURLResponse in
                
                let result = mapResponse((data, httpURLResponse))
                
                switch result {
                case let .failure(error):
                    log("RemoteService: mapResponse failure: \(error): statusCode: \(httpURLResponse.statusCode), data: \(String(data: data, encoding: .utf8) ?? "nil").", file, line)
                    
                case let .success(output):
                    log("RemoteService: mapResponse success: \(output).", file, line)
                }
                
                return result
            }
        )
    }
}

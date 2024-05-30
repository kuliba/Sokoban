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
    
    let remoteService: Decoratee
    
    init(
        createRequest: @escaping CreateRequest,
        performRequest: @escaping Decoratee.PerformRequest,
        mapResponse: @escaping Decoratee.MapResponse,
        log: @escaping Log,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        self.remoteService = .init(
            createRequest: Self.decorate(createRequest: createRequest, with: log, file: file, line: line),
            performRequest: performRequest,
            mapResponse: Self.decorate(mapResponse: mapResponse, with: log, file: file, line: line)
        )
    }
}

extension LoggingRemoteServiceDecorator {
    
    typealias Decoratee = RemoteService<Input, Output, Error, PerformRequestError, MapResponseError>
    typealias CreateRequest = (Input) throws -> URLRequest
    typealias Log = (String, StaticString, UInt) -> Void
}

extension LoggingRemoteServiceDecorator {
    
    func callAsFunction(
        _ input: Input,
        completion: @escaping Decoratee.ProcessCompletion
    ) {
        remoteService(input, completion: completion)
    }
    
    func callAsFunction(
        _ input: Input
    ) async throws -> Output {
        
        return try await remoteService.process(input)
    }
}

private extension LoggingRemoteServiceDecorator {
    
    static func decorate(
        createRequest: @escaping CreateRequest,
        with log: @escaping Log,
        file: StaticString,
        line: UInt
    ) -> CreateRequest {
        
        return { input in
            
            do {
                let request = try createRequest(input)
                log("RemoteService: Created request: \(request.detailedDescription).", file, line)
                return request
            } catch {
                log("RemoteService: request creation error: \(error).", file, line)
                throw error
            }
        }
    }
    
    static func decorate(
        mapResponse: @escaping Decoratee.MapResponse,
        with log: @escaping Log,
        file: StaticString,
        line: UInt
    ) -> Decoratee.MapResponse {
        
        return { response in
            
            let result = mapResponse(response)
            log(Self.mapDescription(response, result), file, line)
            
            return result
        }
    }
    
    static func mapDescription(
        _ response: (data: Data, httpURLResponse: HTTPURLResponse),
        _ result: Result<Output, MapResponseError>
    ) -> String {
        
        let (data, httpURLResponse) = response
        var description = "RemoteService: received response with statusCode \(httpURLResponse.statusCode), data: \(String(data: data, encoding: .utf8) ?? "n/a").\n"
        
        switch result {
        case let .failure(error):
            description.append("RemoteService: mapResponse failure: \(error).")
            
        case let .success(output):
            description.append("RemoteService: mapResponse success: \(type(of: output)).")
        }
        
        return description
    }
}

private extension URLRequest {
    
    var detailedDescription: String {
        
        let urlDescription = url?.absoluteString ?? "n/a"
        let methodDescription = httpMethod ?? "n/a"
        
        var headersDescription = "["
        if let headers = allHTTPHeaderFields {
            headersDescription += headers.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        }
        headersDescription += "]"
        
        let bodyDescription: String
        if let body = httpBody {
            bodyDescription = String(data: body, encoding: .utf8) ?? "n/a"
        } else {
            bodyDescription = "empty body"
        }
        
        return "URL: \(urlDescription), Method: \(methodDescription), Headers: \(headersDescription), Body: \(bodyDescription)"
    }
}

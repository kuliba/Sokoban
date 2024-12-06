//
//  HTTPClientSpy.swift
//  VortexTests
//
//  Created by Igor Malyarov on 01.08.2023.
//

@testable import ForaBank
import Foundation

final class HTTPClientSpy: HTTPClient {
    
    typealias Message = (request: Request, completion: Completion)
    
    private var messages = [Message]()
    var callCount: Int { messages.count }
    
    var requests: [Request] { messages.map(\.request) }
    
    func performRequest(
        _ request: Request,
        completion: @escaping Completion
    ) {
        messages.append((request, completion))
    }
    
    func complete(
        with result: HTTPClient.Result,
        at index: Int = 0
    ) {
        messages[index].completion(result)
    }
}

extension HTTPClientSpy {
    
    func complete(
        with error: Error,
        at index: Int = 0
    ) {
        complete(with: .failure(error), at: index)
    }
    
    func complete(
        with success: (data: Data, response: HTTPURLResponse),
        at index: Int = 0
    ) {
        complete(with: .success((success.data, success.response)), at: index)
    }
    
    func complete(
        with data: Data,
        at index: Int = 0
    ) {
        complete(with: .success((data, okResponse)), at: index)
    }
}

private let okResponse = anyHTTPURLResponse(with: 200)

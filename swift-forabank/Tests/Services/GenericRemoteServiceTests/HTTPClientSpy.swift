//
//  HTTPClientSpy.swift
//
//
//  Created by Igor Malyarov on 16.05.2024.
//

import Foundation

final class HTTPClientSpy<Response> {
    
    func get(
        _ request: URLRequest,
        completion: @escaping PerformCompletion
    ) {
        messages.append((request, completion))
    }
    
    typealias PerformResult = Result<Response, PerformRequestError>
    typealias PerformCompletion = (PerformResult) -> Void
    
    private typealias Message = (
        request: URLRequest,
        completion: PerformCompletion
    )
    
    private var messages = [Message]()
    
    var requests: [URLRequest] { messages.map(\.request) }
    var callCount: Int { requests.count }
    
    func complete(
        with result: PerformResult,
        at index: Int = 0
    ) {
        messages[index].completion(result)
    }
}

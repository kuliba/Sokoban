//
//  HTTPClientStub.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.02.2024.
//

import Foundation
import Tagged

typealias URLPath = Tagged<_URLPath, String>
enum _URLPath {}

final class HTTPClientStub: HTTPClient {
    
    private let stub: Stub
    private let delay: TimeInterval
    
    init(
        stub: Stub,
        delay: TimeInterval = 1
    ) {
        self.stub = stub
        self.delay = delay
    }
    
    func performRequest(
        _ request: Request,
        completion: @escaping Completion
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            
            guard let self else { return }
            
            guard let path = request.urlPath
            else {
                fatalError("Bad URL in URLRequest")
            }
            
            guard let result = stub[path]
            else {
                fatalError("No stub for \"\(path.rawValue)\"")
            }
            
            completion(.success(result))
        }
    }
}

extension HTTPClientStub {
    
    typealias Stub = [URLPath: HTTPClient.Response]
}

private extension URLRequest {
    
    var urlPath: URLPath? { (url?.path).map { .init($0) } }
}

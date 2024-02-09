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
    
    init(stub: Stub) {
        
        self.stub = stub
    }
    
    func performRequest(
        _ request: Request,
        completion: @escaping Completion
    ) {
        guard let path = request.urlPath
        else {
            completion(.failure(HTTPError.badURL))
            return
        }
        
        guard let result = stub[path]
        else {
            completion(.failure(HTTPError.badServerResponse))
            return
        }
        
        completion(.success(result))
    }
}

extension HTTPClientStub {
    
    typealias Stub = [URLPath: HTTPClient.Response]
    
    enum HTTPError: Error {
        
        case badURL
        case badServerResponse
    }
}

private extension URLRequest {
    
    var urlPath: URLPath? { (url?.path).map { .init($0) } }
}

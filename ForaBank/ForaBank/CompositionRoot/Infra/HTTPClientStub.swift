//
//  HTTPClientStub.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.02.2024.
//

import Foundation
import Tagged

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
            
            guard let service = request.service
            else {
                fatalError("Bad URL in URLRequest.")
            }
            
            guard let result = stub[service]
            else {
                fatalError("No stub for \"\(service.rawValue)\".")
            }
            
            completion(.success(result))
        }
    }
}

extension HTTPClientStub {
    
    typealias Stub = [Services.Endpoint.ServiceName: HTTPClient.Response]
}

private extension URLRequest {
    
    var service: Services.Endpoint.ServiceName? {
        
        guard let last = url?.lastPathComponent
        else { return nil }
        
        return .init(rawValue: last)
    }
}

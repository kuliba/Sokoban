//
//  HTTPClientStub.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.02.2024.
//

import Foundation
import Tagged

final class HTTPClientStub: HTTPClient {
    
    private var stub: Stub
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
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delay
        ) { [weak self] in
            
            guard let self else { return }
            
            guard let service = request.service
            else {
                fatalError("Bad URL in URLRequest.")
            }
            
            guard let result = stub[service]
            else {
                fatalError("No stub for \"\(service.rawValue)\".")
            }
            
            switch result {
            case let .constant(response):
                completion(.success(response))
                
            case var .multiple(responses):
                let response = responses.removeFirst()
                stub[service] = .multiple(responses)
                completion(.success(response))
            }
        }
    }
}

extension HTTPClientStub {
    
    typealias Stub = [Services.Endpoint.ServiceName: Response]
    
    enum Response {
        
        case constant(HTTPClient.Response)
        case multiple([HTTPClient.Response])
    }
}

private extension URLRequest {
    
    var service: Services.Endpoint.ServiceName? {
        
        guard let last = url?.lastPathComponent
        else { return nil }
        
        return .init(rawValue: last)
    }
}

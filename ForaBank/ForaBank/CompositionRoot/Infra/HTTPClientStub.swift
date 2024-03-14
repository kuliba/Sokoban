//
//  HTTPClientStub.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.02.2024.
//

import Foundation
import Tagged

final class HTTPClientStub {
    
    private var stub: Stub
    
    init(stub: Stub) {
        
        self.stub = stub
    }
}

extension HTTPClientStub: HTTPClient {
    
    func performRequest(
        _ request: Request,
        completion: @escaping Completion
    ) {
        guard let service = request.service
        else { fatalError("Bad URL in URLRequest.") }
        
        guard let result = stub[service]
        else { fatalError("No stub for \"\(service.rawValue)\".") }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + result.delay
        ) { [weak self] in
            
            guard let self else { return }
            
            switch result.response {
            case let .constant(response):
                completion(.success(response))
                
            case var .multiple(responses):
                let response = responses.removeFirst()
                stub[service] = .init(
                    response: .multiple(responses),
                    delay: result.delay
                )
                completion(.success(response))
            }
        }
    }
}

extension HTTPClientStub {
    
    typealias Stub = [Services.Endpoint.ServiceName: DelayedResponse]
    
    struct DelayedResponse {
        
        let response: Response
        let delay: DispatchTimeInterval
        
        init(
            response: Response,
            delay: DispatchTimeInterval = .seconds(1)
        ) {
            self.response = response
            self.delay = delay
        }
        
        enum Response {
            
            case constant(HTTPClient.Response)
            case multiple([HTTPClient.Response])
        }
    }
}

extension HTTPClientStub {
    
    convenience init(
        _ stub: [Services.Endpoint.ServiceName: [Data]],
        delay: DispatchTimeInterval = .seconds(1)
    ) {
        
        let stub = stub
            .mapValues { $0.map { $0.response(statusCode: 200) }}
            .mapValues(HTTPClientStub.DelayedResponse.Response.multiple)
            .mapValues {
                
                HTTPClientStub.DelayedResponse(
                    response: $0,
                    delay: delay
                )
            }
        
        self.init(stub: stub)
    }
}

private extension URLRequest {
    
    var service: Services.Endpoint.ServiceName? {
        
        guard let last = url?.lastPathComponent
        else { return nil }
        
        return .init(rawValue: last)
    }
}

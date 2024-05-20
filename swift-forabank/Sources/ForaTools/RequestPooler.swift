//
//  RequestPooler.swift
//
//
//  Created by Igor Malyarov on 11.03.2024.
//

public final class RequestPooler<Request: Hashable, Response> {
    
    private var requestQueue = [Request: [Completion]]()
    private let perform: Perform
    
    public init(perform: @escaping Perform) {
        
        self.perform = perform
    }
}

public extension RequestPooler {
    
    func handleRequest(
        _ request: Request,
        _ completion: @escaping Completion
    ) {
        if requestQueue[request] == nil {
            
            requestQueue[request] = [completion]
            perform(request) { [weak self] response in
                
                self?.deliverResponse(response, for: request)
            }
            
        } else {
            
            requestQueue[request]?.append(completion)
        }
    }
}

public extension RequestPooler {
    
    typealias Perform = (Request, @escaping (Response) -> Void) -> Void
    typealias Completion = (Response) -> Void
}

private extension RequestPooler {
    
    func deliverResponse(
        _ response: Response,
        for request: Request
    ) {
        requestQueue[request]?.forEach { [weak self] completion in
            
            guard self != nil else { return }
            
            completion(response)
        }
        requestQueue[request] = nil
    }
}

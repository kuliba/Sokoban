//
//  RequestBundler.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import Foundation

/// A class that batches multiple requests for the same resource and ensures that the requests are only performed once.
/// It stores pending requests and invokes all the completion handlers once the request is completed.
public final class RequestBundler<Request, Response>
where Request: Hashable {
    
    private var pendingRequests: PendingRequests = .init()
    private let performer: any Performer
    private let queue = DispatchQueue(label: "requestBundlerQueue")
    
    /// Initialises a new instance of `RequestBundler`.
    ///
    /// - Parameter performer: The performer responsible for executing the requests.
    public init(
        performer: any Performer
    ) {
        self.performer = performer
    }
    
    public typealias Performer = Loader<Request, Response>
    
    private typealias PendingRequests = [Request: [(Response) -> Void]]
}

extension RequestBundler: Loader {
    
    /// Loads the specified request and calls the completion handler when the response is received.
    /// If there are multiple requests for the same resource, they are batched together and the request is only performed once.
    ///
    /// - Parameters:
    ///   - request: The request to be loaded.
    ///   - completion: The completion handler to be called when the response is received.
    public func load(
        _ request: Request,
        _ completion: @escaping (Response) -> Void
    ) {
        queue.sync {
            
            if pendingRequests[request] == nil {
                pendingRequests[request] = [completion]
                performer.load(request) { [weak self] response in
                    
                    guard let self,
                          let completions = pendingRequests[request]
                    else { return }
                    
                    self.pendingRequests[request] = nil
                    
                    self.queue.async {
                        
                        completions.forEach { $0(response) }
                    }
                }
            } else {
                pendingRequests[request]?.append(completion)
            }
        }
    }
}

//
//  URLSessionHTTPClient.swift
//  
//
//  Created by Igor Malyarov on 31.07.2023.
//

import Foundation

public final class URLSessionHTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession) {
        
        self.session = session
    }
    
    public typealias Response = (Data, HTTPURLResponse)
    public typealias Result = Swift.Result<Response, Error>
    public typealias Completion = (Result) -> Void
    
    public func perform(
        _ request: URLRequest,
        completion: @escaping Completion
    ) {
        // TODO: add logging
        // LoggerAgent.shared.log(category: .network, message: "data request: \(request)")
        
        session.dataTask(with: request) { [weak self] data, response, error in
            
            guard self != nil else {
                
                completion(.failure(.nonHTTPURLResponse))
                return
            }
            
            if let error {
                
                completion(.failure(.sessionError(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                
                completion(.failure(.nonHTTPURLResponse))
                return
            }
            
            guard let data else {
                completion(.failure(.emptyResponseData))
                return
            }
            
            // TODO: add additional handling from ServerAgent.executeCommand(command:completion:) if necessary
            
            completion(.success((data, response)))
        }
        .resume()
    }
    
    public enum Error: Swift.Error {
        
        case sessionError(Swift.Error)
        case nonHTTPURLResponse
        case emptyResponseData
    }
}

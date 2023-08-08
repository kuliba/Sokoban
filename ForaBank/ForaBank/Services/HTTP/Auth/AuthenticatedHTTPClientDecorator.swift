//
//  AuthenticatedHTTPClientDecorator.swift
//
//
//  Created by Igor Malyarov on 27.07.2023.
//

import Foundation

public final class AuthenticatedHTTPClientDecorator: HTTPClient {
    
    public typealias SignRequest = (URLRequest, TokenProvider.Token) -> URLRequest
    
    private let decoratee: HTTPClient
    private let tokenProvider: TokenProvider
    private let signRequest: SignRequest
    
    private let pendingTokenRequestsQueue = DispatchQueue(label: "pendingTokenRequestsQueue")
    private var pendingTokenRequests = [TokenProvider.Completion]()
    
    public init(
        decoratee: HTTPClient,
        tokenProvider: TokenProvider,
        signRequest: @escaping SignRequest
    ) {
        self.decoratee = decoratee
        self.tokenProvider = tokenProvider
        self.signRequest = signRequest
    }
    
    public func performRequest(
        _ request: Request,
        completion: @escaping Completion
    ) {
        pendingTokenRequestsQueue.sync {
            
            pendingTokenRequests.append { [weak self] tokenResult in
                
                self?.handleTokenResult(tokenResult, request, completion)
            }
        }
        
        guard pendingTokenRequests.count == 1 else { return }
        
        tokenProvider.getToken { [weak self] result in
            
            self?.pendingTokenRequests.forEach { $0(result) }
            self?.pendingTokenRequests = []
        }
    }
    
    private func handleTokenResult(
        _ tokenResult: Result<String, Error>,
        _ request: Request,
        _ completion: @escaping Completion
    ) {
        switch tokenResult {
        case let .failure(error):
            completion(.failure(error))
            
        case let .success(token):
            let signedRequest = signRequest(request, token)
            
            decoratee.performRequest(signedRequest) { [weak self] in
                
                guard self != nil else { return }
                
                completion($0)
            }
        }
    }
}

//
//  AuthenticateWithPublicKeyService.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

import Foundation

/// Step 2.1 `authenticateWithPublicKey`
/// - Note: `SessionKey` is `SymmetricKey` is `SharedSecret`
///
public final class AuthenticateWithPublicKeyService {
    
    public typealias PrepareKeyExchangeResult = Swift.Result<Data, Swift.Error>
    public typealias PrepareKeyExchangeCompletion = (PrepareKeyExchangeResult) -> Void
    public typealias PrepareKeyExchange = (@escaping PrepareKeyExchangeCompletion) -> Void
    
    public typealias ProcessResult = Swift.Result<Response, APIError>
    public typealias ProcessCompletion = (ProcessResult) -> Void
    public typealias Process = (Data, @escaping ProcessCompletion) -> Void
    
    public typealias MakeSessionKeyResult = Swift.Result<Success.SessionKey, Swift.Error>
    public typealias MakeSessionKeyCompletion = (MakeSessionKeyResult) -> Void
    public typealias MakeSessionKey = (Response, @escaping MakeSessionKeyCompletion) -> Void
    
    private let prepareKeyExchange: PrepareKeyExchange
    private let process: Process // processPublicKeyAuthenticationRequest
    private let makeSessionKey: MakeSessionKey
    
    public init(
        prepareKeyExchange: @escaping PrepareKeyExchange,
        process: @escaping Process,
        makeSessionKey: @escaping MakeSessionKey
    ) {
        self.prepareKeyExchange = prepareKeyExchange
        self.process = process
        self.makeSessionKey = makeSessionKey
    }
}

public extension AuthenticateWithPublicKeyService {
    
    typealias Result = Swift.Result<Success, Error>
    typealias Completion = (Result) -> Void
    
    func authenticateWithPublicKey(
        completion: @escaping Completion
    ) {
        prepareKeyExchange(completion)
    }
    
    enum Error: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        case serviceError(ServiceError)
        
        public enum ServiceError {
            case activationFailure
            case makeSessionKeyFailure
            case missingRSAPublicKey
            case prepareKeyExchangeFailure
        }
    }
}

extension AuthenticateWithPublicKeyService {
    
    public enum APIError: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
    }
    
    public struct Response {
        
        public let sessionID: String
        public let publicServerSessionKey: String
        public let sessionTTL: Int
        
        public init(
            sessionID: String,
            publicServerSessionKey: String,
            sessionTTL: Int
        ) {
            self.sessionID = sessionID
            self.publicServerSessionKey = publicServerSessionKey
            self.sessionTTL = sessionTTL
        }
    }
    
    public struct Success {
        
        public let sessionID: SessionID
        public let sessionKey: SessionKey
        public let sessionTTL: SessionTTL
        
        public init(
            sessionID: SessionID,
            sessionKey: SessionKey,
            sessionTTL: SessionTTL
        ) {
            self.sessionID = sessionID
            self.sessionKey = sessionKey
            self.sessionTTL = sessionTTL
        }
        
        public struct SessionID {
            
            public let sessionIDValue: String
            
            public init(sessionIDValue: String) {
                
                self.sessionIDValue = sessionIDValue
            }
        }
        
        public typealias SessionTTL = Int
        
        public struct SessionKey {
            
            public let sessionKeyValue: Data
            
            public init(sessionKeyValue: Data) {
                
                self.sessionKeyValue = sessionKeyValue
            }
        }
    }
}

private extension AuthenticateWithPublicKeyService {
    
    func prepareKeyExchange(
        _ completion: @escaping Completion
    ) {
        prepareKeyExchange { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.serviceError(.prepareKeyExchangeFailure)))
                
            case let .success(data):
                process(data, completion)
            }
        }
    }
    
    func process(
        _ data: Data,
        _ completion: @escaping Completion
    ) {
        process(data) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(.init(error)))
                
            case let .success(response):
                _makeSessionKey(response, completion)
            }
        }
    }
    
    func _makeSessionKey(
        _ response: Response,
        _ completion: @escaping Completion
    ) {
        makeSessionKey(response) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(
                result
                    .map {
                        .init(
                            sessionID: .init(sessionIDValue: response.sessionID),
                            sessionKey: $0,
                            sessionTTL: .init(response.sessionTTL)
                        )
                    }
                    .mapError { _ in .serviceError(.makeSessionKeyFailure)}
            )
        }
    }
}

// MARK: - Error Mapping

private extension AuthenticateWithPublicKeyService.Error {
    
    init(_ error: AuthenticateWithPublicKeyService.APIError) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let.server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

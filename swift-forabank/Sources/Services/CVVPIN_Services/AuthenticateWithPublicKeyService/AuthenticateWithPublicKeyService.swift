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
final class AuthenticateWithPublicKeyService<RSAPublicKey, SessionKey> {
    
    typealias LoadRSAPublicKeyResult = Swift.Result<RSAPublicKey, Swift.Error>
    typealias LoadRSAPublicKeyCompletion = (LoadRSAPublicKeyResult) -> Void
    typealias LoadRSAPublicKey = (@escaping LoadRSAPublicKeyCompletion) -> Void
    
    typealias LoadSessionKeyResult = Swift.Result<SessionKey, Swift.Error>
    typealias LoadSessionKeyCompletion = (LoadSessionKeyResult) -> Void
    typealias LoadSessionKey = (@escaping LoadSessionKeyCompletion) -> Void
    
    typealias PrepareKeyExchangeResult = Swift.Result<Payload, Swift.Error>
    typealias PrepareKeyExchangeCompletion = (PrepareKeyExchangeResult) -> Void
    typealias PrepareKeyExchange = (@escaping PrepareKeyExchangeCompletion) -> Void
    
    typealias ProcessResult = Swift.Result<Response, APIError>
    typealias ProcessCompletion = (ProcessResult) -> Void
    typealias Process = (Payload, @escaping ProcessCompletion) -> Void
    
    typealias ActivateCCVPINResult = Swift.Result<SessionKey, Swift.Error>
    typealias ActivateCCVPINCompletion = (ActivateCCVPINResult) -> Void
    typealias ActivateCCVPIN = (Swift.Error, @escaping ActivateCCVPINCompletion) -> Void
    
    typealias MakeSessionKeyResult = Swift.Result<SessionKey, Swift.Error>
    typealias MakeSessionKeyCompletion = (MakeSessionKeyResult) -> Void
    typealias MakeSessionKey = (String, @escaping MakeSessionKeyCompletion) -> Void
    
    private let loadRSAPublicKey: LoadRSAPublicKey
    private let loadSessionKey: LoadSessionKey
    private let prepareKeyExchange: PrepareKeyExchange
    // processPublicKeyAuthenticationRequest
    private let process: Process
    private let activateCCVPIN: ActivateCCVPIN
    private let makeSessionKey: MakeSessionKey
    
    init(
        loadRSAPublicKey: @escaping LoadRSAPublicKey,
        loadSessionKey: @escaping LoadSessionKey,
        prepareKeyExchange: @escaping PrepareKeyExchange,
        process: @escaping Process,
        activateCCVPIN: @escaping ActivateCCVPIN,
        makeSessionKey: @escaping MakeSessionKey
    ) {
        self.loadRSAPublicKey = loadRSAPublicKey
        self.loadSessionKey = loadSessionKey
        self.prepareKeyExchange = prepareKeyExchange
        self.process = process
        self.activateCCVPIN = activateCCVPIN
        self.makeSessionKey = makeSessionKey
    }
}

extension AuthenticateWithPublicKeyService {
    
    typealias Result = Swift.Result<SessionKey, Error>
    typealias Completion = (Result) -> Void
    
    func authenticateWithPublicKey(
        completion: @escaping Completion
    ) {
        loadRSAPublicKey(completion)
    }
    
    enum Error: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case server(statusCode: Int, errorMessage: String)
        case other(Other)
        
        enum Other {
            
            case activationFailure
            case makeSessionKeyFailure
            case missingRSAPublicKey
            case prepareKeyExchangeFailure
        }
    }
    
    enum APIError: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case server(statusCode: Int, errorMessage: String)
    }
    
    struct Payload {
        
        let clientPublicKeyRSA: String
        let publicApplicationSessionKey: String
        let signature: String
    }
    
    struct Response {
        
        let sessionID: String
        let publicServerSessionKey: String
        let sessionTTL: Int
    }
}

private extension AuthenticateWithPublicKeyService {
    
    func loadRSAPublicKey(
        _ completion: @escaping Completion
    ) {
        loadRSAPublicKey { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                activateCCVPIN(.other(.missingRSAPublicKey), completion)
                
            case .success:
                loadSessionKey(completion)
            }
        }
    }
    
    func activateCCVPIN(
        _ error: Error,
        _ completion: @escaping Completion
    ) {
        activateCCVPIN(error) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError { _ in .other(.activationFailure) })
        }
    }
    
    func loadSessionKey(
        _ completion: @escaping Completion
    ) {
        loadSessionKey { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                prepareKeyExchange(completion)
                
            case let .success(sessionKey):
                completion(.success(sessionKey))
            }
        }
    }
    
    func prepareKeyExchange(
        _ completion: @escaping Completion
    ) {
        prepareKeyExchange { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.other(.prepareKeyExchangeFailure)))
                
            case let .success(payload):
                process(payload, completion)
            }
        }
    }
    
    func process(
        _ payload: Payload,
        _ completion: @escaping Completion
    ) {
        process(payload) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                activateCCVPIN(.init(error), completion)
                
            case let .success(response):
                makeSessionKey(response, completion)
            }
        }
    }
    
    func makeSessionKey(
        _ response: Response,
        _ completion: @escaping Completion
    ) {
        makeSessionKey(
            response.publicServerSessionKey
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError { _ in .other(.makeSessionKeyFailure)})
        }
    }
}

private extension AuthenticateWithPublicKeyService.Error {
    
    init(
        _ error: AuthenticateWithPublicKeyService.APIError
    ) {
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case let.server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

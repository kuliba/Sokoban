//
//  ShowCVVService.swift
//
//
//  Created by Igor Malyarov on 20.10.2023.
//

import Foundation

public final class ShowCVVService {
    
    public typealias AuthenticateResult = Swift.Result<SessionID, AuthenticateError>
    public typealias AuthenticateCompletion = (AuthenticateResult) -> Void
    public typealias Authenticate = (@escaping AuthenticateCompletion) -> Void
    
    public typealias MakeJSONResult = Swift.Result<Data, Swift.Error>
    public typealias MakeJSONCompletion = (MakeJSONResult) -> Void
    public typealias MakeJSON = (CardID, SessionID, @escaping MakeJSONCompletion) -> Void
    
    public typealias ProcessResult = Swift.Result<EncryptedCVV, APIError>
    public typealias ProcessCompletion = (ProcessResult) -> Void
    public typealias Process = (Payload, @escaping ProcessCompletion) -> Void
    
    public typealias DecryptCVVResult = Swift.Result<CVV, Swift.Error>
    public typealias DecryptCVVCompletion = (DecryptCVVResult) -> Void
    public typealias DecryptCVV = (EncryptedCVV, @escaping DecryptCVVCompletion) -> Void
    
    private let authenticate: Authenticate
    private let makeJSON: MakeJSON
    private let process: Process
    private let decryptCVV: DecryptCVV
    
    public init(
        authenticate: @escaping Authenticate,
        makeJSON: @escaping MakeJSON,
        process: @escaping Process,
        decryptCVV: @escaping DecryptCVV
    ) {
        self.authenticate = authenticate
        self.makeJSON = makeJSON
        self.process = process
        self.decryptCVV = decryptCVV
    }
}

public extension ShowCVVService {
    
    typealias Result = Swift.Result<CVV, Error>
    typealias Completion = (Result) -> Void
    
    func showCVV(
        cardID: CardID,
        completion: @escaping Completion
    ) {
        _authenticate(cardID, completion)
    }
    
    enum Error: Swift.Error {
        
        case activationFailure
        case authenticationFailure
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        case serviceError(ServiceError)
        
        public enum ServiceError {
            
            case decryptionFailure
            case makeJSONFailure
        }
    }
}

extension ShowCVVService {
    
    public enum AuthenticateError: Swift.Error {
        
        case activationFailure
        case authenticationFailure
    }
    
    public enum APIError: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case connectivity
        case server(statusCode: Int, errorMessage: String)
    }
    
    public struct CardID {
        
        public let cardIDValue: Int
        
        public init(cardIDValue: Int) {
            
            self.cardIDValue = cardIDValue
        }
    }
    
    public struct EncryptedCVV {
        
        public let encryptedCVVValue: String
        
        public init(encryptedCVVValue: String) {
            
            self.encryptedCVVValue = encryptedCVVValue
        }
    }
    
    public struct CVV {
        
        public let cvvValue: String
        
        public init(cvvValue: String) {
            
            self.cvvValue = cvvValue
        }
    }
    
    public struct SessionID {
        
        public let sessionIDValue: String
        
        public init(sessionIDValue: String) {
            
            self.sessionIDValue = sessionIDValue
        }
    }
    
    public struct Payload {
        
        public let sessionID: SessionID
        public let data: Data
    }
}

private extension ShowCVVService {
    
    func _authenticate(
        _ cardID: CardID,
        _ completion: @escaping Completion
    ) {
        authenticate { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(.init(error)))
                
            case let .success(sessionID):
                _makeJSON(cardID, sessionID, completion)
            }
        }
    }
    
    func _makeJSON(
        _ cardID: CardID,
        _ sessionID: SessionID,
        _ completion: @escaping Completion
    ) {
        makeJSON(cardID, sessionID) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.serviceError(.makeJSONFailure)))
                
            case let .success(json):
                _process(sessionID, json, completion)
            }
        }
    }
    
    func _process(
        _ sessionID: SessionID,
        _ data: Data,
        _ completion: @escaping Completion
    ) {
        process(
            .init(sessionID: sessionID, data: data)
        ) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(apiError):
                completion(.failure(.init(apiError)))
                
            case let .success(encryptedCVV):
                _decrypt(encryptedCVV, completion)
            }
        }
    }
    
    func _decrypt(
        _ encryptedCVV: EncryptedCVV,
        _ completion: @escaping Completion
    ) {
        decryptCVV(encryptedCVV) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError { _ in .serviceError(.decryptionFailure) })
        }
    }
}

// MARK: - Error Mapping

private extension ShowCVVService.Error {
    
    init( _ error: ShowCVVService.AuthenticateError) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
            
        case .authenticationFailure:
            self = .authenticationFailure
        }
    }
    
    init(_ error: ShowCVVService.APIError) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .connectivity:
            self = .network
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

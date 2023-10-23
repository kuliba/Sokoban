//
//  ShowCVVService.swift
//
//
//  Created by Igor Malyarov on 20.10.2023.
//

import Foundation

public final class ShowCVVService {
    
    public typealias CheckSessionResult = Swift.Result<SessionID, Swift.Error>
    public typealias CheckSessionCompletion = (CheckSessionResult) -> Void
    public typealias CheckSession = (@escaping CheckSessionCompletion) -> Void
    
    public typealias MakeJSONResult = Swift.Result<Data, Error>
    public typealias MakeJSONCompletion = (MakeJSONResult) -> Void
    public typealias MakeJSON = (CardID, SessionID, @escaping MakeJSONCompletion) -> Void
    
    public typealias ProcessResult = Swift.Result<EncryptedCVV, APIError>
    public typealias ProcessCompletion = (ProcessResult) -> Void
    public typealias Process = (Payload, @escaping ProcessCompletion) -> Void
    
    public typealias DecryptCVVResult = Swift.Result<CVV, Error>
    public typealias DecryptCVVCompletion = (DecryptCVVResult) -> Void
    public typealias DecryptCVV = (EncryptedCVV, @escaping DecryptCVVCompletion) -> Void
    
    private let checkSession: CheckSession
    private let makeJSON: MakeJSON
    private let process: Process
    private let decryptCVV: DecryptCVV
    
    public init(
        checkSession: @escaping CheckSession,
        makeJSON: @escaping MakeJSON,
        process: @escaping Process,
        decryptCVV: @escaping DecryptCVV
    ) {
        self.checkSession = checkSession
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
        checkSession(cardID, completion)
    }
    
    enum Error: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        case other(Other)
        
        public enum Other {
            
            case checkSessionFailure
            case decryptionFailure
            case makeJSONFailure
        }
    }
    
    enum APIError: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
    }
}

extension ShowCVVService {
    
    public struct CardID {
        
        let cardID: Int
        
        public init(cardID: Int) {
         
            self.cardID = cardID
        }
    }
    
    public struct EncryptedCVV {
        
        public let encryptedCVV: String
        
        public init(encryptedCVV: String) {
         
            self.encryptedCVV = encryptedCVV
        }
    }
    
    public struct CVV {
        
        public let cvv: String
        
        public init(cvv: String) {
         
            self.cvv = cvv
        }
    }
    
    public struct SessionID {
        
        public let sessionID: String
        
        public init(sessionID: String) {
            
            self.sessionID = sessionID
        }
    }
    
    public struct Payload {
        
        public let sessionID: SessionID
        public let data: Data
    }
}

private extension ShowCVVService {
    
    func checkSession(
        _ cardID: CardID,
        _ completion: @escaping Completion
    ) {
        checkSession { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.other(.checkSessionFailure)))
                
            case let .success(sessionID):
                makeJSON(cardID, sessionID, completion)
            }
        }
    }
    
    func makeJSON(
        _ cardID: CardID,
        _ sessionID: SessionID,
        _ completion: @escaping Completion
    ) {
        makeJSON(cardID, sessionID) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.other(.makeJSONFailure)))
                
            case let .success(json):
                process(sessionID, json, completion)
            }
        }
    }
    
    func process(
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
                decrypt(encryptedCVV, completion)
            }
        }
    }
    
    func decrypt(
        _ encryptedCVV: EncryptedCVV,
        _ completion: @escaping Completion
    ) {
        decryptCVV(encryptedCVV) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError { _ in .other(.decryptionFailure) })
        }
    }
}

private extension ShowCVVService.Error {
    
    init(
        _ error: ShowCVVService.APIError
    ) {
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

//
//  ChangePINService.swift
//  
//
//  Created by Igor Malyarov on 05.10.2023.
//

import Foundation

public final class ChangePINService<APIError, CardID, EventID, OTP, PIN, RSAPrivateKey, SessionID, SymmetricKey>
where APIError: Error {
    
    public typealias MakePINChangeJSON = (SessionID, CardID, OTP, PIN, EventID) throws -> Data
    public typealias MakeSecretPINRequest = (SessionID, Data, SymmetricKey) throws -> Data
    
    private let infra: Infra
    private let makePINChangeJSON: MakePINChangeJSON
    private let makeSecretPINRequest: MakeSecretPINRequest
    
    public init(
        infra: Infra,
        makePINChangeJSON: @escaping MakePINChangeJSON,
        makeSecretPINRequest: @escaping MakeSecretPINRequest
    ) {
        self.infra = infra
        self.makePINChangeJSON = makePINChangeJSON
        self.makeSecretPINRequest = makeSecretPINRequest
    }
}

public extension ChangePINService {
    
    typealias Completion = (Result<Void, ChangePINError<APIError>>) -> Void
    
    func changePIN(
        cardID: CardID,
        otp: OTP,
        pin: PIN,
        completion: @escaping Completion
    ) {
        loadSessionID(cardID, otp, pin, completion)
    }
}

// MARK: - Interface

public enum ChangePINError<APIError>: Error {
    
    case apiError(APIError)
    case makeSecretPINRequestFailure
    case missing(Missing)
    
    public enum Missing: Equatable {
        
        case eventID
        case rsaPrivateKey
        case sessionID
        case symmetricKey
    }
}

extension ChangePINService {
    
    public struct Infra {
        
        public typealias SessionIDDomain = DomainOf<SessionID>
        public typealias LoadSessionID = SessionIDDomain.AsyncGet
        
        public typealias SymmetricKeyDomain = DomainOf<SymmetricKey>
        public typealias LoadSymmetricKey = SymmetricKeyDomain.AsyncGet
        
        public typealias EventIDDomain = DomainOf<EventID>
        public typealias LoadEventID = EventIDDomain.AsyncGet
        
        public typealias ProcessResult = Result<Void, APIError>
        public typealias ProcessCompletion = (ProcessResult) -> Void
        public typealias Process = ((SessionID, Data), @escaping ProcessCompletion) -> Void
        
        let loadSessionID: LoadSessionID
        let loadSymmetricKey: LoadSymmetricKey
        let loadEventID: LoadEventID
        let process: Process
        
        public init(
            loadSessionID: @escaping LoadSessionID,
            loadSymmetricKey: @escaping LoadSymmetricKey,
            loadEventID: @escaping LoadEventID,
            process: @escaping Process
        ) {
            self.loadSessionID = loadSessionID
            self.loadSymmetricKey = loadSymmetricKey
            self.loadEventID = loadEventID
            self.process = process
        }
    }
}

// MARK: - Implementation

private extension ChangePINService {
    
    func loadSessionID(
        _ cardID: CardID,
        _ otp: OTP,
        _ pin: PIN,
        _ completion: @escaping Completion
    ) {
        infra.loadSessionID { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.missing(.sessionID)))
                
            case let .success(sessionID):
                loadSymmetricKey(cardID, otp, pin, sessionID, completion)
            }
        }
    }
    
    func loadSymmetricKey(
        _ cardID: CardID,
        _ otp: OTP,
        _ pin: PIN,
        _ sessionID: SessionID,
        _ completion: @escaping Completion
    ) {
        infra.loadSymmetricKey { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.missing(.symmetricKey)))
                
            case let .success(symmetricKey):
                loadEventID(cardID, otp, pin, sessionID, symmetricKey, completion)
            }
        }
    }
    
    func loadEventID(
        _ cardID: CardID,
        _ otp: OTP,
        _ pin: PIN,
        _ sessionID: SessionID,
        _ symmetricKey: SymmetricKey,
        _ completion: @escaping Completion
    ) {
        infra.loadEventID { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.missing(.eventID)))
                
            case let .success(eventID):
                process(cardID, otp, pin, sessionID, symmetricKey, eventID, completion)
            }
        }
    }
    
    func process(
        _ cardID: CardID,
        _ otp: OTP,
        _ pin: PIN,
        _ sessionID: SessionID,
        _ symmetricKey: SymmetricKey,
        _ eventID: EventID,
        _ completion: @escaping Completion
    ) {
        do {
            let pinChangeJSON = try makePINChangeJSON(sessionID, cardID, otp, pin, eventID)
            let request = try makeSecretPINRequest(sessionID, pinChangeJSON, symmetricKey)
            
            infra.process((sessionID, request)) { [weak self] result in
                
                guard self != nil else { return }
                
                completion(result.mapError { ChangePINError.apiError($0) })
            }
        } catch {
            completion(.failure(.makeSecretPINRequestFailure))
        }
    }
}

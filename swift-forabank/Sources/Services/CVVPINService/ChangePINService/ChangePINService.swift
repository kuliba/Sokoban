//
//  ChangePINService.swift
//  
//
//  Created by Igor Malyarov on 05.10.2023.
//

import Foundation

public final class ChangePINService<APIError, CardID, EventID, OTP, PIN, RSAPrivateKey, SessionID, SymmetricKey>
where APIError: Error {
    
    public typealias MakePINChangeJSON = (SessionID, CardID, OTP, PIN, EventID, RSAPrivateKey) throws -> Data
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
    
    typealias Completion = (ChangePINError<APIError>?) -> Void
    
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
        
        public typealias RSAPrivateKeyDomain = DomainOf<RSAPrivateKey>
        public typealias LoadRSAPrivateKey = RSAPrivateKeyDomain.AsyncGet
        
        public typealias ProcessCompletion = (APIError?) -> Void
        public typealias Process = (Data, @escaping ProcessCompletion) -> Void
        
        let loadSessionID: LoadSessionID
        let loadSymmetricKey: LoadSymmetricKey
        let loadEventID: LoadEventID
        let loadRSAPrivateKey: LoadRSAPrivateKey
        let process: Process
        
        public init(
            loadSessionID: @escaping LoadSessionID,
            loadSymmetricKey: @escaping LoadSymmetricKey,
            loadEventID: @escaping LoadEventID,
            loadRSAPrivateKey: @escaping LoadRSAPrivateKey,
            process: @escaping Process
        ) {
            self.loadSessionID = loadSessionID
            self.loadSymmetricKey = loadSymmetricKey
            self.loadEventID = loadEventID
            self.loadRSAPrivateKey = loadRSAPrivateKey
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
                completion(.missing(.sessionID))
                
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
                completion(.missing(.symmetricKey))
                
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
                completion(.missing(.eventID))
                
            case let .success(eventID):
                loadRSAPrivateKey(cardID, otp, pin, sessionID, symmetricKey, eventID, completion)
            }
        }
    }
    
    func loadRSAPrivateKey(
        _ cardID: CardID,
        _ otp: OTP,
        _ pin: PIN,
        _ sessionID: SessionID,
        _ symmetricKey: SymmetricKey,
        _ eventID: EventID,
        _ completion: @escaping Completion
    ) {
        infra.loadRSAPrivateKey { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.missing(.rsaPrivateKey))
                
            case let .success(rsaPrivateKey):
                process(cardID, otp, pin, sessionID, symmetricKey, eventID, rsaPrivateKey, completion)
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
        _ rsaPrivateKey: RSAPrivateKey,
        _ completion: @escaping Completion
    ) {
        do {
            let pinChangeJSON = try makePINChangeJSON(sessionID, cardID, otp, pin, eventID, rsaPrivateKey)
            let request = try makeSecretPINRequest(sessionID, pinChangeJSON, symmetricKey)
            
            infra.process(request) { [weak self] result in
                
                guard self != nil else { return }
                
                completion(result.map { ChangePINError.apiError($0) })
            }
        } catch {
            completion(.makeSecretPINRequestFailure)
        }
    }
}

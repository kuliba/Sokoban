//
//  ShowCVVService.swift
//  
//
//  Created by Igor Malyarov on 03.10.2023.
//

import Foundation

public final class ShowCVVService<APIError, CardID, RemoteCVV, CVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
where APIError: Error,
      CardID: RawRepresentable<Int>,
      SessionID: RawRepresentable<String> {
    
    public typealias Infra = ShowCVVInfra<APIError, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
    public typealias RSAKeyPairDomain = KeyPairDomain<RSAPublicKey, RSAPrivateKey>
    public typealias MakeJSON = (CardID, SessionID, RSAPublicKey, RSAPrivateKey, SymmetricKey) throws -> Data
    public typealias TranscodeCVV = (RemoteCVV, RSAPrivateKey) throws -> CVV
    
    private let infra: Infra
    private let makeJSON: MakeJSON
    private let transcodeCVV: TranscodeCVV
    
    public init(
        infra: Infra,
        makeJSON: @escaping MakeJSON,
        transcodeCVV: @escaping TranscodeCVV
    ) {
        self.infra = infra
        self.makeJSON = makeJSON
        self.transcodeCVV = transcodeCVV
    }
}

public extension ShowCVVService {
    
    typealias CVVDomain = Domain<CVV, ShowCVVError<APIError>>
    typealias CVVCompletion = CVVDomain.Completion
    
    func showCVV(
        forCardWithID cardID: CardID,
        completion: @escaping CVVCompletion
    ) {
        infra.loadRSAKeyPair { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.missing(.rsaKeyPair)))
                
            case let .success(keyPair):
                loadSessionID(cardID, keyPair, completion)
            }
        }
    }
}

// MARK: - Interface

public enum ShowCVVError<APIError>: Error {
    
    case apiError(APIError)
    case makeJSONFailure
    case missing(Missing)
    case transcodeFailure
    
    public enum Missing: Equatable {
        
        case rsaKeyPair
        case sessionID
        case symmetricKey
    }
}

public struct ShowCVVInfra<APIError, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
where APIError: Error {
    
    public typealias RSAKeyPairDomain = KeyPairDomain<RSAPublicKey, RSAPrivateKey>
    public typealias LoadRSAKeyPair = RSAKeyPairDomain.AsyncGet
    
    public typealias SessionIDDomain = DomainOf<SessionID>
    public typealias LoadSessionID = SessionIDDomain.AsyncGet
    
    public typealias SymmetricKeyDomain = DomainOf<SymmetricKey>
    public typealias LoadSymmetricKey = SymmetricKeyDomain.AsyncGet
    
    public typealias ServiceDomain = RemoteServiceDomain<(SessionID, Data), RemoteCVV, APIError>
    public typealias Process = ServiceDomain.AsyncGet
    
    let loadRSAKeyPair: LoadRSAKeyPair
    let loadSessionID: LoadSessionID
    let loadSymmetricKey: LoadSymmetricKey
    let process: Process
    
    public init(
        loadRSAKeyPair: @escaping LoadRSAKeyPair,
        loadSessionID: @escaping LoadSessionID,
        loadSymmetricKey: @escaping LoadSymmetricKey,
        process: @escaping Process
    ) {
        self.loadRSAKeyPair = loadRSAKeyPair
        self.loadSessionID = loadSessionID
        self.loadSymmetricKey = loadSymmetricKey
        self.process = process
    }
}

// MARK: - Implementation

private extension ShowCVVService {
    
    func loadSessionID(
        _ cardID: CardID,
        _ keyPair: RSAKeyPairDomain.KeyPair,
        _ completion: @escaping CVVCompletion
    ) {
        infra.loadSessionID { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.missing(.sessionID)))
                
            case let .success(sessionID):
                loadSymmetricKey(cardID, keyPair, sessionID, completion)
            }
        }
    }
    
    func loadSymmetricKey(
        _ cardID: CardID,
        _ keyPair: RSAKeyPairDomain.KeyPair,
        _ sessionID: SessionID,
        _ completion: @escaping CVVCompletion
    ) {
        infra.loadSymmetricKey { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.missing(.symmetricKey)))
                
            case let .success(symmetricKey):
                process(cardID, keyPair, sessionID, symmetricKey, completion)
            }
        }
    }
    
    func process(
        _ cardID: CardID,
        _ keyPair: RSAKeyPairDomain.KeyPair,
        _ sessionID: SessionID,
        _ symmetricKey: SymmetricKey,
        _ completion: @escaping CVVCompletion
    ) {
        do {
            let (publicKey, privateKey) = keyPair
            let transcode: (RemoteCVV) throws -> CVV = { [transcodeCVV] in
                try transcodeCVV($0, privateKey)
            }
            
            let json = try makeJSON(cardID, sessionID, publicKey, privateKey, symmetricKey)
            
            infra.process((sessionID, json)) { [weak self] result in
                
                guard self != nil else { return }
                
                switch result {
                    
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                    
                case let .success(remoteCVV):
                    do {
                        let cvv = try transcode(remoteCVV)
                        completion(.success(cvv))
                    } catch {
                        completion(.failure(.transcodeFailure))
                    }
                }
            }
        } catch {
            completion(.failure(.makeJSONFailure))
        }
    }
}

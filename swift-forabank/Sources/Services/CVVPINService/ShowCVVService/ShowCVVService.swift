//
//  ShowCVVService.swift
//  
//
//  Created by Igor Malyarov on 03.10.2023.
//

import Foundation

public final class ShowCVVService<CardID, RemoteCVV, CVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
where CardID: RawRepresentable<Int>,
      SessionID: RawRepresentable<String> {
    
    public typealias Infra = ShowCVVInfra<RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
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
    
    typealias CVVDomain = DomainOf<CVV>
    typealias CVVCompletion = CVVDomain.Completion
    
    func showCVV(
        forCardWithID cardID: CardID,
        completion: @escaping CVVCompletion
    ) {
        infra.loadRSAKeyPair { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(keyPair):
                loadSessionID(cardID, keyPair, completion)
            }
        }
    }
}

// MARK: - Interface

public struct ShowCVVInfra<RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey> {
    
    public typealias RSAKeyPairDomain = KeyPairDomain<RSAPublicKey, RSAPrivateKey>
    public typealias LoadRSAKeyPair = RSAKeyPairDomain.AsyncGet
    
    public typealias SessionIDDomain = DomainOf<SessionID>
    public typealias LoadSessionID = SessionIDDomain.AsyncGet
    
    public typealias SymmetricKeyDomain = DomainOf<SymmetricKey>
    public typealias LoadSymmetricKey = SymmetricKeyDomain.AsyncGet
    
    public typealias ServiceDomain = RemoteServiceDomain<Data, RemoteCVV, Error>
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
            case let .failure(error):
                completion(.failure(error))
                
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
            case let .failure(error):
                completion(.failure(error))
                
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
            
            infra.process(json) { [weak self] result in
                
                guard self != nil else { return }
                
                completion(result.map(transcode))
            }
        } catch {
            completion(.failure(error))
        }
    }
}

private extension Result where Failure == Error {
    
    func map<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) -> Result<NewSuccess, Failure> {
        
        .init { try transform(get()) }
    }
}

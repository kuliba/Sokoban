//
//  Services+makeBindPublicKeyService.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation
import GenericRemoteService

extension Services {
    
    typealias BindPublicKeyService = Fetcher<BindPublicKeyWithEventIDService.Payload, RSADomain.KeyPair, BindPublicKeyWithEventIDService.Failure>
    
    typealias LoadSessionIDResult = Result<SessionID, Error>
    typealias LoadSessionIDCompletion = (LoadSessionIDResult) -> Void
    typealias LoadSessionID = (@escaping LoadSessionIDCompletion) -> Void
    
    typealias LoadSessionKeyResult = Result<SessionKey, Error>
    typealias LoadSessionKeyCompletion = (LoadSessionKeyResult) -> Void
    typealias LoadSessionKey = (@escaping LoadSessionKeyCompletion) -> Void
    
    typealias ProcessBindPublicKeyError = MappingRemoteServiceError<BindPublicKeyWithEventIDService.APIError>
    typealias ProcessBindPublicKey = (BindPublicKeyWithEventIDService.ProcessPayload, @escaping (Result<Void, ProcessBindPublicKeyError>) -> Void) -> Void
    
    typealias MakeSecretJSON = (String, SessionKey) throws -> (Data, RSADomain.KeyPair)
    
    typealias CacheLog = (LoggerAgentLevel, String, StaticString, UInt) -> ()
    
        static func makeBindPublicKeyService(
        loadSessionID: @escaping LoadSessionID,
        loadSessionKey: @escaping LoadSessionKey,
        processBindPublicKey: @escaping ProcessBindPublicKey,
        makeSecretJSON: @escaping MakeSecretJSON,
        cacheLog: @escaping CacheLog,
        currentDate: @escaping () -> Date = Date.init,
        ephemeralLifespan: TimeInterval
    ) -> any BindPublicKeyService {
        
        let rsaKeyPairLoader = loggingLoader(
            store: InMemoryStore<RSADomain.KeyPair>()
        )
        
        let eventIDFetcher = FetchAdapter(
            loadSessionID,
            map: BindPublicKeyWithEventIDService.EventID.init
        )
        
        let bindPublicKeyRemote = FetchAdapter(
            fetch: processBindPublicKey,
            mapError: BindPublicKeyWithEventIDService.APIError.init
        )
        
        let bindPublicKeyService = BindPublicKeyWithEventIDService(
            loadEventID: eventIDFetcher.fetch(completion:),
            makeSecretJSON: __makeSecretJSON,
            process: bindPublicKeyRemote.fetch(_:completion:)
        )
        
        typealias BindResult = Result<RSADomain.KeyPair, BindPublicKeyWithEventIDService.Failure>
        typealias Bind = (BindPublicKeyWithEventIDService.OTP, @escaping (BindResult) -> Void) -> Void
        
        let bind: Bind = { otp, completion in
            
            bindPublicKeyService.bind(with: otp) { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case .success(()):
                    rsaKeyPairLoader.load { result in
                        
                        switch result {
                        case .failure:
#warning("REPLACE WITH NEW ERROR TYPE HERE")
                            completion(.failure(.serviceError(.makeJSONFailure)))
                            
                        case let .success(rsaKeyPair):
                            completion(.success(rsaKeyPair))
                        }
                    }
                }
            }
        }
        
        return FetchAdapter(fetch: bind)
        
        // MARK: - Helpers
        
#warning("REPEATED")
        func loggingLoader<T>(
            store: any Store<T>
        ) -> any Loader<T> {
            
            LoggingLoaderDecorator(
                decoratee: GenericLoaderOf(
                    store: store,
                    currentDate: currentDate
                ),
                log: cacheLog
            )
        }
        
        // MARK: - BindPublicKeyWithEventID Adapters
        
        func __makeSecretJSON(
            otp: BindPublicKeyWithEventIDService.OTP,
            completion: @escaping BindPublicKeyWithEventIDService.SecretJSONCompletion
        ) {
            loadSessionKey { result in
                
                do {
                    let sessionKey = try result.get()
                    let (data, rsaKeyPair) = try makeSecretJSON(
                        otp.otpValue,
                        sessionKey
                    )
                    
                    rsaKeyPairLoader.save(
                        rsaKeyPair,
                        validUntil: currentDate().addingTimeInterval(ephemeralLifespan)
                    ) {
                        completion($0.map { _ in data })
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - Mappers

private extension BindPublicKeyWithEventIDService.EventID {
    
    init(_ sessionID: SessionID) {
        
        self.init(eventIDValue: sessionID.sessionIDValue)
    }
}

private extension BindPublicKeyWithEventIDService.APIError {
    
    init(_ error: MappingRemoteServiceError<BindPublicKeyWithEventIDService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

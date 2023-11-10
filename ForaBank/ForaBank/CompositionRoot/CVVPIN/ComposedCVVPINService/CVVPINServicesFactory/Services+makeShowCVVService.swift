//
//  Services+makeShowCVVService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation

extension Services {
    
    typealias _ShowCVVRemoteService = Fetcher<(SessionID, Data), ShowCVVService.EncryptedCVV, MappingRemoteServiceError<ShowCVVService.APIError>>
    
    static func makeShowCVVService(
        rsaKeyPairLoader: any Loader<RSADomain.KeyPair>,
        sessionIDLoader: any Loader<SessionID>,
        sessionKeyLoader: any Loader<SessionKey>,
        authWithPublicKeyService: any AuthWithPublicKeyFetcher,
        showCVVRemoteService: any _ShowCVVRemoteService,
        cvvPINCrypto: CVVPINCrypto,
        cvvPINJSONMaker: CVVPINJSONMaker
    ) -> ShowCVVService {
        
        let showCVVService = ShowCVVService(
            authenticate: authenticate,
            makeJSON: makeSecretJSON,
            process: process,
            decryptCVV: decryptCVV
        )
        
        return showCVVService
        
        // MARK: - ShowCVV Adapters
        
        func authenticate(
            completion: @escaping ShowCVVService.AuthenticateCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                case .failure:
                    completion(.failure(.activationFailure))
                    
                case let .success(rsaKeyPair):
                    authenticate(rsaKeyPair, completion)
                }
            }
        }
        
        func authenticate(
            _ rsaKeyPair: RSADomain.KeyPair,
            _ completion: @escaping ShowCVVService.AuthenticateCompletion
        ) {
            sessionIDLoader.load { result in
                
                switch result {
                case .failure:
                    authWithPublicKeyService.fetch {
                        
                        completion(
                            $0
                                .map(\.sessionID.sessionIDValue)
                                .map(ShowCVVService.SessionID.init)
                                .mapError { _ in .authenticationFailure })
                    }
                    
                case let .success(sessionID):
                    completion(.success(
                        .init(sessionIDValue: sessionID.value)
                    ))
                }
            }
        }
        
        func makeSecretJSON(
            cardID: ShowCVVService.CardID,
            sessionID: ShowCVVService.SessionID,
            completion: @escaping ShowCVVService.MakeJSONCompletion
        ) {
            loadShowCVVSession { result in
                
                completion(.init {
                    
                    let session = try result.get()
                    return try cvvPINJSONMaker.makeShowCVVSecretJSON(
                        with: cardID,
                        and: sessionID,
                        rsaKeyPair: session.rsaKeyPair,
                        sessionKey: session.sessionKey
                    )
                })
            }
        }
        
        func process(
            payload: ShowCVVService.Payload,
            completion: @escaping ShowCVVService.ProcessCompletion
        ) {
            showCVVRemoteService.fetch((
                .init(value: payload.sessionID.sessionIDValue),
                payload.data
            )) {
                completion($0.mapError { .init($0) })
            }
        }
        
        func decryptCVV(
            encryptedCVV: ShowCVVService.EncryptedCVV,
            completion: @escaping ShowCVVService.DecryptCVVCompletion
        ) {
            loadShowCVVSession {
                
                do {
                    let rsaKeyPair = try $0.get().rsaKeyPair
                    let cvvValue = try cvvPINCrypto.rsaDecrypt(
                        encryptedCVV.encryptedCVVValue,
                        withPrivateKey: rsaKeyPair.privateKey
                    )
                    completion(.success(.init(cvvValue: cvvValue)))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        typealias LoadShowCVVSessionResult = Swift.Result<ShowCVVSession, Error>
        typealias LoadShowCVVSessionCompletion = (LoadShowCVVSessionResult) -> Void
        
        func loadShowCVVSession(
            completion: @escaping LoadShowCVVSessionCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let.success(rsaKeyPair):
                    loadShowCVVSession(rsaKeyPair, completion)
                }
            }
        }
        
        func loadShowCVVSession(
            _ rsaKeyPair: RSADomain.KeyPair,
            _ completion: @escaping LoadShowCVVSessionCompletion
        ) {
            sessionKeyLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(sessionKey):
                    completion(.success(.init(
                        rsaKeyPair: rsaKeyPair,
                        sessionKey: sessionKey
                    )))
                }
            }
        }
        
        struct ShowCVVSession {
            
            let rsaKeyPair: RSADomain.KeyPair
            let sessionKey: SessionKey
        }
        
    }
}

private extension ShowCVVService.APIError {
    
    init(_ error: MappingRemoteServiceError<ShowCVVService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .connectivity
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

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
    
    typealias LoadShowCVVSessionResult = Result<ShowCVVSession, Error>
    typealias LoadShowCVVSessionCompletion = (LoadShowCVVSessionResult) -> Void
    typealias LoadShowCVVSession = (@escaping LoadShowCVVSessionCompletion) -> Void
    
    typealias DecryptString = (String, RSADomain.PrivateKey) throws -> String
    
    typealias MakeShowCVVSecretJSON = (ShowCVVService.CardID, ShowCVVService.SessionID, RSADomain.KeyPair, SessionKey) throws -> Data
    
    typealias _ShowCVVRemoteService = Fetcher<(SessionID, Data), ShowCVVService.EncryptedCVV, MappingRemoteServiceError<ShowCVVService.APIError>>
    
    static func makeShowCVVService(
        auth: @escaping Auth,
        loadSession: @escaping LoadShowCVVSession,
        showCVVRemoteService: any _ShowCVVRemoteService,
        decryptString: @escaping DecryptString,
        makeShowCVVSecretJSON: @escaping MakeShowCVVSecretJSON
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
            auth { result in
                
                completion(
                    result
                        .map(\.sessionIDValue)
                        .map(ShowCVVService.SessionID.init)
                        .mapError(ShowCVVService.AuthenticateError.init)
                )
            }
        }
        
        func makeSecretJSON(
            cardID: ShowCVVService.CardID,
            sessionID: ShowCVVService.SessionID,
            completion: @escaping ShowCVVService.MakeJSONCompletion
        ) {
            loadSession { result in
                
                completion(.init {
                    
                    let session = try result.get()
                    return try makeShowCVVSecretJSON(
                        cardID,
                        sessionID,
                        session.rsaKeyPair,
                        session.sessionKey
                    )
                })
            }
        }
        
        func process(
            payload: ShowCVVService.Payload,
            completion: @escaping ShowCVVService.ProcessCompletion
        ) {
            showCVVRemoteService.fetch((
                .init(sessionIDValue: payload.sessionID.sessionIDValue),
                payload.data
            )) {
                completion($0.mapError(ShowCVVService.APIError.init))
            }
        }
        
        func decryptCVV(
            encryptedCVV: ShowCVVService.EncryptedCVV,
            completion: @escaping ShowCVVService.DecryptCVVCompletion
        ) {
            loadSession {
                
                do {
                    let rsaKeyPair = try $0.get().rsaKeyPair
                    let cvvValue = try decryptString(
                        encryptedCVV.encryptedCVVValue,
                        rsaKeyPair.privateKey
                    )
                    completion(.success(.init(cvvValue: cvvValue)))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    struct ShowCVVSession {
        
        let rsaKeyPair: RSADomain.KeyPair
        let sessionKey: SessionKey
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

private extension ShowCVVService.AuthenticateError {
    
    init(_ error: Services.AuthError) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
        
        case .authenticationFailure:
            self = .authenticationFailure
        }
    }
}

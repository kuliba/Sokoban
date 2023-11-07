//
//  Services+makeChangePINService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.11.2023.
//

import CVVPIN_Services
import Foundation

extension Services {
    
#warning("replace CachingAuthWithPublicKeyServiceDecorator with protocol")
    static func makeChangePINService(
        rsaKeyPairLoader: any Loader<RSAKeyPair>,
        sessionIDLoader: any Loader<SessionID>,
        otpEventIDLoader: any Loader<ChangePINService.OTPEventID>,
        sessionKeyLoader: any Loader<SessionKey>,
        cachingAuthWithPublicKeyService: CachingAuthWithPublicKeyServiceDecorator,
        confirmChangePINRemoteService: ConfirmChangePINRemoteService,
        changePINRemoteService: Services.ChangePINRemoteService,
        cvvPINCrypto: CVVPINCrypto,
        cvvPINJSONMaker: CVVPINJSONMaker,
        currentDate: @escaping () -> Date = Date.init,
        ephemeralLifespan: TimeInterval
    ) -> ChangePINService {
        
        let changePINService = ChangePINService(
            authenticate: authenticate,
            publicRSAKeyDecrypt: publicRSAKeyDecrypt,
            confirmProcess: confirmProcess,
            makePINChangeJSON: makePINChangeJSON,
            changePINProcess: changePINProcess
        )

        return changePINService
        
        // MARK: - ChangePIN Adapters
        
        func authenticate(
            completion: @escaping ChangePINService.AuthenticateCompletion
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
            _ rsaKeyPair: RSAKeyPair,
            _ completion: @escaping ChangePINService.AuthenticateCompletion
        ) {
            sessionIDLoader.load { result in
                
                switch result {
                case .failure:
                    cachingAuthWithPublicKeyService.authenticateWithPublicKey {
                        
                        completion(
                            $0
                                .map(\.sessionID.sessionIDValue)
                                .map(ChangePINService.SessionID.init(sessionIDValue:))
                                .mapError { _ in .authenticationFailure })
                    }
                    
                case let .success(sessionID):
                    completion(.success(.init(
                        sessionIDValue: sessionID.value
                    )))
                }
            }
        }
        
        typealias LoadChangePINSessionCompletion = (Result<ChangePINSession, Error>) -> Void
        
        func loadSession(
            completion: @escaping LoadChangePINSessionCompletion
        ) {
            otpEventIDLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(otpEventID):
                    loadSession(otpEventID, completion)
                }
            }
        }
        
        func loadSession(
            _ otpEventID: ChangePINService.OTPEventID,
            _ completion: @escaping LoadChangePINSessionCompletion
        ) {
            sessionIDLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(sessionID):
                    loadSession(otpEventID, sessionID, completion)
                }
            }
        }
        
        func loadSession(
            _ otpEventID: ChangePINService.OTPEventID,
            _ sessionID: SessionID,
            _ completion: @escaping LoadChangePINSessionCompletion
        ) {
            sessionKeyLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(sessionKey):
                    loadSession(otpEventID, sessionID, sessionKey, completion)
                }
            }
        }
        
        func loadSession(
            _ otpEventID: ChangePINService.OTPEventID,
            _ sessionID: SessionID,
            _ sessionKey: SessionKey,
            _ completion: @escaping LoadChangePINSessionCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(rsaKeyPair):
                    completion(.success(.init(
                        otpEventID: otpEventID,
                        sessionID: sessionID,
                        sessionKey: sessionKey,
                        rsaPrivateKey: rsaKeyPair.privateKey
                    )))
                }
            }
        }
        
        struct ChangePINSession {
            
            let otpEventID: ChangePINService.OTPEventID
            let sessionID: ForaBank.SessionID
            let sessionKey: SessionKey
            let rsaPrivateKey: RSADomain.PrivateKey
        }
        
        func publicRSAKeyDecrypt(
            string: String,
            completion: @escaping ChangePINService.PublicRSAKeyDecryptCompletion
        ) {
            rsaKeyPairLoader.load { result in
                
                switch result {
                    
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(keyPair):
                    completion(.init {
                        
                        try cvvPINCrypto.rsaDecrypt(
                            string,
                            withPrivateKey: keyPair.privateKey
                        )
                    })
                }
            }
        }
        
        func confirmProcess(
            sessionID: ChangePINService.SessionID,
            completion: @escaping ChangePINService.ConfirmProcessCompletion
        ) {
            confirmChangePINRemoteService.process(
                .init(value: sessionID.sessionIDValue)
            ) {
                completion(
                    $0
                        .map { .init(eventID: $0.eventID, phone: $0.phone) }
                        .mapError { .init($0) }
                )
            }
        }
        
        func makePINChangeJSON(
            cardID: ChangePINService.CardID,
            pin: ChangePINService.PIN,
            otp: ChangePINService.OTP,
            completion: @escaping ChangePINService.MakePINChangeJSONCompletion
        ) {
            loadSession { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(session):
                    let sessionID = ChangePINService.SessionID(
                        sessionIDValue: session.sessionID.value
                    )
                    
                    completion(.init {
                        
                        let json = try cvvPINJSONMaker.makePINChangeJSON(
                            sessionID: sessionID,
                            cardID: .init(cardIDValue: cardID.cardIDValue),
                            otp: .init(otpValue: otp.otpValue),
                            pin: .init(pinValue: pin.pinValue),
                            otpEventID: session.otpEventID,
                            sessionKey: session.sessionKey,
                            rsaPrivateKey: session.rsaPrivateKey
                        )
                        
                        return (sessionID, json)
                    })
                }
            }
        }
        
        func changePINProcess(
            payload: (ChangePINService.SessionID, Data),
            completion: @escaping ChangePINService.ChangePINProcessCompletion
        ) {
            changePINRemoteService.process((
                .init(value: payload.0.sessionIDValue),
                payload.1
            )) {
                completion($0.mapError { .init($0) })
            }
        }
    }
}

private extension ChangePINService.ConfirmAPIError {
    
    init(_ error: MappingRemoteServiceError<ChangePINService.ConfirmAPIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

private extension ChangePINService.ChangePINAPIError {
    
    init(_ error: MappingRemoteServiceError<ChangePINService.ChangePINAPIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

//
//  Services+makeChangePINService.swift
//  Vortex
//
//  Created by Igor Malyarov on 05.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation

extension Services {
    
    typealias LoadChangePinSessionResult = Result<ChangePINSession, Error>
    typealias LoadChangePinSessionCompletion = (LoadChangePinSessionResult) -> Void
    typealias LoadChangePinSession = (@escaping LoadChangePinSessionCompletion) -> Void
    
    typealias DecryptStringCompletion = (Result<String, Error>) -> Void
    typealias AsyncDecryptString = (String, @escaping DecryptStringCompletion) -> Void
    
    typealias MakePINChangeJSON = (ChangePINService.SessionID, ChangePINService.CardID, ChangePINService.OTP, ChangePINService.PIN, ChangePINService.OTPEventID, SessionKey, RSADomain.PrivateKey) throws -> Data
    
    typealias _ChangePINRemoteService = Fetcher<(SessionID, Data), Void, MappingRemoteServiceError<ChangePINService.ChangePINAPIError>>
    typealias _ConfirmChangePINRemoteService = Fetcher<SessionID, ChangePINService.EncryptedConfirmResponse, MappingRemoteServiceError<ChangePINService.ConfirmAPIError>>
    
    static func makeChangePINService(
        auth: @escaping Auth,
        loadSession: @escaping LoadChangePinSession,
        changePINRemoteService: any _ChangePINRemoteService,
        confirmChangePINRemoteService: any _ConfirmChangePINRemoteService,
        publicRSAKeyDecrypt: @escaping AsyncDecryptString,
        _makePINChangeJSON: @escaping MakePINChangeJSON
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
            auth { result in
                
                completion(
                    result
                        .map(\.sessionIDValue)
                        .map(ChangePINService.SessionID.init)
                        .mapError(ChangePINService.AuthenticateError.init)
                )
            }
        }
        
        func confirmProcess(
            sessionID: ChangePINService.SessionID,
            completion: @escaping ChangePINService.ConfirmProcessCompletion
        ) {
            confirmChangePINRemoteService.fetch(
                .init(sessionIDValue: sessionID.sessionIDValue)
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
                        sessionIDValue: session.sessionID.sessionIDValue
                    )
                    
                    completion(.init {
                        
                        let json = try _makePINChangeJSON(
                            sessionID,
                            .init(cardIDValue: cardID.cardIDValue),
                            .init(otpValue: otp.otpValue),
                            .init(pinValue: pin.pinValue),
                            session.otpEventID,
                            session.sessionKey,
                            session.rsaPrivateKey
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
            changePINRemoteService.fetch((
                .init(sessionIDValue: payload.0.sessionIDValue),
                payload.1
            )) {
                completion($0.mapError { .init($0) })
            }
        }
    }
    
    struct ChangePINSession {
        
        let otpEventID: ChangePINService.OTPEventID
        let sessionID: ForaBank.SessionID
        let sessionKey: SessionKey
        let rsaPrivateKey: RSADomain.PrivateKey
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

private extension ChangePINService.AuthenticateError {
    
    init(_ error: Services.AuthError) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
            
        case .authenticationFailure:
            self = .authenticationFailure
        }
    }
}

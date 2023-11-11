//
//  Services+makeChangePINService.swift
//  ForaBank
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
    typealias StringDecryptCompletion = (Result<String, Error>) -> Void
    typealias StringDecrypt = (String, @escaping StringDecryptCompletion) -> Void
    
    typealias _ChangePINRemoteService = Fetcher<(SessionID, Data), Void, MappingRemoteServiceError<ChangePINService.ChangePINAPIError>>
    typealias _ConfirmChangePINRemoteService = Fetcher<SessionID, ChangePINService.EncryptedConfirmResponse, MappingRemoteServiceError<ChangePINService.ConfirmAPIError>>
    
    static func makeChangePINService(
        auth: @escaping Auth,
        loadSession: @escaping LoadChangePinSession,
        changePINRemoteService: any _ChangePINRemoteService,
        confirmChangePINRemoteService: any _ConfirmChangePINRemoteService,
        publicRSAKeyDecrypt: @escaping StringDecrypt,
        cvvPINJSONMaker: CVVPINJSONMaker
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
                        .map(\.value)
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
            changePINRemoteService.fetch((
                .init(value: payload.0.sessionIDValue),
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

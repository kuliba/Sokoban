//
//  ChangePINService.swift
//
//
//  Created by Igor Malyarov on 20.10.2023.
//

import Foundation

public final class ChangePINService {
    
    public typealias AuthenticateResult = Swift.Result<SessionID, AuthenticateError>
    public typealias AuthenticateCompletion = (AuthenticateResult) -> Void
    public typealias Authenticate = (@escaping AuthenticateCompletion) -> Void

    public typealias PublicRSAKeyDecryptResult = Swift.Result<String, Swift.Error>
    public typealias PublicRSAKeyDecryptCompletion = (PublicRSAKeyDecryptResult) -> Void
    public typealias PublicRSAKeyDecrypt = (String, @escaping PublicRSAKeyDecryptCompletion) -> Void
    
    public typealias ConfirmProcessResult = Swift.Result<EncryptedConfirmResponse, ConfirmAPIError>
    public typealias ConfirmProcessCompletion = (ConfirmProcessResult) -> Void
    public typealias ConfirmProcess = (SessionID, @escaping ConfirmProcessCompletion) -> Void
    
    public typealias MakePINChangeJSONResult = Swift.Result<(SessionID, Data), Swift.Error>
    public typealias MakePINChangeJSONCompletion = (MakePINChangeJSONResult) -> Void
    public typealias MakePINChangeJSON = (CardID, PIN, OTP, @escaping MakePINChangeJSONCompletion) -> Void
    
    public typealias ChangePINProcessResult = Swift.Result<Void, ChangePINAPIError>
    public typealias ChangePINProcessCompletion = (ChangePINProcessResult) -> Void
    public typealias ChangePINProcess = ((SessionID, Data), @escaping ChangePINProcessCompletion) -> Void
    
    private let authenticate: Authenticate
    private let publicRSAKeyDecrypt: PublicRSAKeyDecrypt
    private let confirmProcess: ConfirmProcess
    private let makePINChangeJSON: MakePINChangeJSON
    private let changePINProcess: ChangePINProcess
    
    public init(
        authenticate: @escaping Authenticate,
        publicRSAKeyDecrypt: @escaping PublicRSAKeyDecrypt,
        confirmProcess: @escaping ConfirmProcess,
        makePINChangeJSON: @escaping MakePINChangeJSON,
        changePINProcess: @escaping ChangePINProcess
    ) {
        self.authenticate = authenticate
        self.publicRSAKeyDecrypt = publicRSAKeyDecrypt
        self.confirmProcess = confirmProcess
        self.makePINChangeJSON = makePINChangeJSON
        self.changePINProcess = changePINProcess
    }
}

public extension ChangePINService {
    
    typealias GetPINConfirmationCodeResult = Swift.Result<ConfirmResponse, Error>
    typealias GetPINConfirmationCodeCompletion = (GetPINConfirmationCodeResult) -> Void
    
    func getPINConfirmationCode(
        completion: @escaping GetPINConfirmationCodeCompletion
    ) {
        _authenticate(completion)
    }
}

public extension ChangePINService {
    
    typealias ChangePINResult = Swift.Result<Void, Error>
    typealias ChangePINCompletion = (ChangePINResult) -> Void
    
    func changePIN(
        for cardID: CardID,
        to pin: PIN,
        otp: OTP,
        completion: @escaping ChangePINCompletion
    ) {
        makePINChangeJSON(cardID, pin, otp, completion)
    }
}

extension ChangePINService {
    
    public enum Error: Swift.Error {
        
        case activationFailure
        case authenticationFailure
        case invalid(statusCode: Int, data: Data)
        case network
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case other(Other)
        
        public enum Other {
            
            case checkSessionFailure
            case decryptionFailure
            case makeJSONFailure
        }
    }
    
    public enum AuthenticateError: Swift.Error {
        
        case activationFailure
        case authenticationFailure
    }
    
    public enum ConfirmAPIError: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
    }
    
    public enum ChangePINAPIError: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
    }
    
    public struct ConfirmResponse {
        
        public let otpEventID: OTPEventID
        public let phone: String
    }
    
    public struct EncryptedConfirmResponse {
        
        public let eventID: String
        public let phone: String
        
        public init(
            eventID: String,
            phone: String
        ) {
            self.eventID = eventID
            self.phone = phone
        }
    }
    
    public struct CardID {
        
        public let cardIDValue: Int
        
        public init(cardIDValue: Int) {
         
            self.cardIDValue = cardIDValue
        }
    }
    
    public struct OTPEventID {
        
        public let eventIDValue: String
        
        public init(eventIDValue: String) {

            self.eventIDValue = eventIDValue
        }
    }
    
    public struct OTP {
        
        public let otpValue: String
        
        public init(otpValue: String) {
         
            self.otpValue = otpValue
        }
    }
    
    public struct PIN {
        
        public let pinValue: String
        
        public init(pinValue: String) {
         
            self.pinValue = pinValue
        }
    }
    
    public struct SessionID {
        
        public let sessionIDValue: String
        
        public init(sessionIDValue: String) {
         
            self.sessionIDValue = sessionIDValue
        }
    }
}

private extension ChangePINService {
    
    func _authenticate(
        _ completion: @escaping GetPINConfirmationCodeCompletion
    ) {
        authenticate { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(.init(error)))

            case let .success(sessionID):
                confirmProcess(sessionID, completion)
            }
        }
    }
    
    func confirmProcess(
        _ sessionID: SessionID,
        _ completion: @escaping GetPINConfirmationCodeCompletion
    ) {
        confirmProcess(sessionID) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(.init(error)))
                
            case let .success(encrypted):
                decrypt(encrypted, completion)
            }
        }
    }
    
    func decrypt(
        _ encrypted: EncryptedConfirmResponse,
        _ completion: @escaping GetPINConfirmationCodeCompletion
    ) {
        publicRSAKeyDecrypt(encrypted.eventID) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.other(.decryptionFailure)))
                
            case let .success(eventID):
                decrypt(.init(eventIDValue: eventID), encrypted, completion)
            }
        }
    }
    
    func decrypt(
        _ eventID: OTPEventID,
        _ encrypted: EncryptedConfirmResponse,
        _ completion: @escaping GetPINConfirmationCodeCompletion
    ) {
        publicRSAKeyDecrypt(encrypted.phone) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(
                result
                    .map { .init(otpEventID: eventID, phone: $0)}
                    .mapError { _ in .other(.decryptionFailure) }
            )
        }
    }
}

private extension ChangePINService {
    
    func makePINChangeJSON(
        _ cardID: CardID,
        _ pin: PIN,
        _ otp: OTP,
        _ completion: @escaping ChangePINCompletion
    ) {
        makePINChangeJSON(cardID, pin, otp) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.other(.makeJSONFailure)))
                
            case let .success((json, sessionID)):
                changePINProcess(sessionID, json, completion)
            }
        }
    }
    
    func changePINProcess(
        _ json: Data,
        _ sessionID: SessionID,
        _ completion: @escaping ChangePINCompletion
    ) {
        changePINProcess((sessionID, json)) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError(Error.init))
        }
    }
}

private extension ChangePINService.Error {
    
    init( _ error: ChangePINService.AuthenticateError) {
        
        switch error {
        case .activationFailure:
            self = .activationFailure
            
        case .authenticationFailure:
            self = .authenticationFailure
        }
    }
    
    init(_ error: ChangePINService.ConfirmAPIError) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }

    init(_ error: ChangePINService.ChangePINAPIError) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts):
            self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

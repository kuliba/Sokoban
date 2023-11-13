//
//  BindPublicKeyWithEventIDService.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

import Foundation

/// Step 1.3 `sendPublicKey`
public final class BindPublicKeyWithEventIDService {
    
    public typealias EventIDResult = Swift.Result<EventID, Swift.Error>
    public typealias EventIDCompletion = (EventIDResult) -> Void
    public typealias LoadEventID = (@escaping EventIDCompletion) -> Void
    
    public typealias SecretJSONResult = Swift.Result<Data, Swift.Error>
    public typealias SecretJSONCompletion = (SecretJSONResult) -> Void
    public typealias MakeSecretJSON = (OTP, @escaping SecretJSONCompletion) -> Void
    
    public typealias ProcessResult = Swift.Result<Void, APIError>
    public typealias ProcessCompletion = (ProcessResult) -> Void
    public typealias Process = (ProcessPayload, @escaping ProcessCompletion) -> Void
    
    private let loadEventID: LoadEventID
    private let makeSecretJSON: MakeSecretJSON
    private let process: Process
    
    public init(
        loadEventID: @escaping LoadEventID,
        makeSecretJSON: @escaping MakeSecretJSON,
        process: @escaping Process
    ) {
        self.loadEventID = loadEventID
        self.makeSecretJSON = makeSecretJSON
        self.process = process
    }
}

public extension BindPublicKeyWithEventIDService {
    
    typealias Result = Swift.Result<Void, Error>
    typealias Completion = (Result) -> Void
    
    func bind(
        with otp: OTP,
        completion: @escaping Completion
    ) {
        loadEventID(otp, completion)
    }
    
    enum Error: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case serviceError(ServiceError)
        
        public enum ServiceError {
            
            case makeJSONFailure
            case missingEventID
        }
    }
}

extension BindPublicKeyWithEventIDService {
    
    public enum APIError: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
    }
    
    public struct EventID {
        
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
    
    public struct ProcessPayload {
        
        public let eventID: EventID
        public let data: Data
    }
}

private extension BindPublicKeyWithEventIDService {
    
    func loadEventID(
        _ otp: OTP,
        _ completion: @escaping Completion
    ) {
        loadEventID { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.serviceError(.missingEventID)))
                
            case let .success(eventID):
                makeSecretJSON(otp, eventID, completion)
            }
        }
    }
    
    func makeSecretJSON(
        _ otp: OTP,
        _ eventID: EventID,
        _ completion: @escaping Completion
    ) {
        makeSecretJSON(otp) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.serviceError(.makeJSONFailure)))
                
            case let .success(json):
                process(eventID, json, completion)
            }
        }
    }
    
    func process(
        _ eventID: EventID,
        _ data: Data,
        _ completion: @escaping Completion
    ) {
        process(
            .init(eventID: eventID, data: data)
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError(Error.init))
        }
    }
}

// MARK: - Error Mapping

private extension BindPublicKeyWithEventIDService.Error {
    
    init(_ error: BindPublicKeyWithEventIDService.APIError) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .retry(statusCode, errorMessage, retryAttempts):
            self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

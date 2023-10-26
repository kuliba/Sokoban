//
//  FormSessionKeyService.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

import Foundation

/// Step 1.2 `getSessionKey`
/// - Note: `SessionKey` is `SymmetricKey` is `SharedSecret`
///
public final class FormSessionKeyService {
    
    public typealias CodeResult = Swift.Result<Code, Swift.Error>
    public typealias CodeCompletion = (CodeResult) -> Void
    public typealias LoadCode = (@escaping CodeCompletion) -> Void
    
    public typealias SecretRequestJSONResult = Swift.Result<Data, Swift.Error>
    public typealias SecretRequestJSONCompletion = (SecretRequestJSONResult) -> Void
    public typealias MakeSecretRequestJSON = (@escaping SecretRequestJSONCompletion) -> Void
    
    public typealias ProcessResult = Swift.Result<Response, APIError>
    public typealias ProcessCompletion = (ProcessResult) -> Void
    public typealias Process = (Payload, @escaping ProcessCompletion) -> Void
    
    public typealias MakeSessionKeyResult = Swift.Result<SessionKey, Swift.Error>
    public typealias MakeSessionKeyCompletion = (MakeSessionKeyResult) -> Void
    public typealias MakeSessionKey = (String, @escaping MakeSessionKeyCompletion) -> Void
    
    private let loadCode: LoadCode
    private let makeSecretRequestJSON: MakeSecretRequestJSON
    private let process: Process
    private let makeSessionKey: MakeSessionKey
    
    public init(
        loadCode: @escaping LoadCode,
        makeSecretRequestJSON: @escaping MakeSecretRequestJSON,
        process: @escaping Process,
        makeSessionKey: @escaping MakeSessionKey
    ) {
        self.loadCode = loadCode
        self.makeSecretRequestJSON = makeSecretRequestJSON
        self.process = process
        self.makeSessionKey = makeSessionKey
    }
}

public extension FormSessionKeyService {
    
    typealias Result = Swift.Result<Success, Error>
    typealias Completion = (Result) -> Void
    
    func formSessionKey(
        completion: @escaping Completion
    ) {
        loadCode(completion)
    }
    
    enum Error: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        case other(Other)
        
        public enum Other {
            
            case missingCode
            case makeJSONFailure
            case makeSessionKeyFailure
        }
    }
    
    enum APIError: Swift.Error {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
    }
}

extension FormSessionKeyService {
    
    public struct Success {
        
        public let sessionKey: SessionKey
        public let eventID: EventID
        public let sessionTTL: SessionTTL
        
        public typealias SessionTTL = Int

        public struct EventID {
            
            public let eventIDValue: String
            
            public init(eventIDValue: String) {
             
                self.eventIDValue = eventIDValue
            }
        }
    }
    
    public struct SessionKey {
        
        public let sessionKeyValue: Data
        
        public init(sessionKeyValue: Data) {
         
            self.sessionKeyValue = sessionKeyValue
        }
    }
    
    public struct Code {
        
        public let codeValue: String
        
        public init(codeValue: String) {
            
            self.codeValue = codeValue
        }
    }
    
    public struct Payload {
        
        public let code: Code
        public let data: Data
        
        public init(
            code: Code,
            data: Data
        ) {
            self.code = code
            self.data = data
        }
    }
    
    public struct Response {
        
        public let publicServerSessionKey: String
        public let eventID: String
        public let sessionTTL: Int
        
        public init(
            publicServerSessionKey: String,
            eventID: String,
            sessionTTL: Int
        ) {
            self.publicServerSessionKey = publicServerSessionKey
            self.eventID = eventID
            self.sessionTTL = sessionTTL
        }
    }
}

private extension FormSessionKeyService {
    
    func loadCode(
        _ completion: @escaping Completion
    ) {
        loadCode { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.other(.missingCode)))
                
            case let .success(code):
                makeSecretRequestJSON(code, completion)
            }
        }
    }
    
    func makeSecretRequestJSON(
        _ code: Code,
        _ completion: @escaping Completion
    ) {
        makeSecretRequestJSON { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.other(.makeJSONFailure)))
                
            case let .success(json):
                process(code, json, completion)
            }
        }
    }
    
    func process(
        _ code: Code,
        _ json: Data,
        _ completion: @escaping Completion
    ) {
        process(
            .init(code: code, data: json)
        ) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(apiError):
                completion(.failure(.init(apiError)))
                
            case let .success(response):
                makeSessionKey(response, completion)
            }
        }
    }
    
    func makeSessionKey(
        _ response: Response,
        _ completion: @escaping Completion
    ) {
        makeSessionKey(
            response.publicServerSessionKey
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(
                result
                    .map {
                        .init(
                            sessionKey: $0,
                            eventID: .init(eventIDValue: response.eventID),
                            sessionTTL: response.sessionTTL
                        )
                    }
                    .mapError { _ in .other(.makeSessionKeyFailure) }
            )
        }
    }
}

private extension FormSessionKeyService.Error {
    
    init(_ error: FormSessionKeyService.APIError) {
        
        switch error {
        case let .invalid(statusCode, data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode, errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
        }
    }
}

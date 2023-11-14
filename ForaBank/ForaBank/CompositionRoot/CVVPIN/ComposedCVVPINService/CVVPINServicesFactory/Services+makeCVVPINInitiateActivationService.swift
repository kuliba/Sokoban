//
//  Services+makeCVVPINInitiateActivationService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation

extension Services {
    
    typealias MakeSecretRequestJSON = () throws -> Data
    typealias ExtractSharedSecret = (String) throws -> Data
    
    static func makeCVVPINInitiateActivationService(
        extractSharedSecret: @escaping ExtractSharedSecret,
        makeSecretRequestJSON: @escaping MakeSecretRequestJSON,
        processGetCode: @escaping Services.ProcessGetCode,
        processFormSessionKey: @escaping Services.ProcessFormSessionKey
    ) -> CVVPINInitiateActivationService {
        
        // MARK: - Configure Sub-Services
        
        let adaptedGetCodeService = FetchAdapter(
            processGetCode,
            map: CVVPINInitiateActivationService.GetCodeSuccess.init,
            mapError: CVVPINInitiateActivationService.GetCodeResponseError.init
        )
        
        let formSessionKeyService = FormSessionKeyService(
            makeSecretRequestJSON: _makeSecretRequestJSON,
            process: process(payload:completion:),
            makeSessionKey: _makeSessionKey
        )
        
        let adaptedFormSessionKeyService = FetchAdapter(
            fetch: formSessionKeyService.formSessionKey(_:completion:),
            map: CVVPINInitiateActivationService.FormSessionKeySuccess.init,
            mapError: CVVPINInitiateActivationService.FormSessionKeyError.init
        )
        
        return CVVPINInitiateActivationService(
            getCode: adaptedGetCodeService.fetch,
            formSessionKey: { code, completion in
                
                adaptedFormSessionKeyService.fetch(
                    .init(codeValue: code.codeValue),
                    completion: completion
                )
            }
        )
        
        // MARK: - FormSessionKey Adapters
        
        func process(
            payload: FormSessionKeyService.ProcessPayload,
            completion: @escaping FormSessionKeyService.ProcessCompletion
        ) {
            processFormSessionKey(
                .init(code: payload.code, data: payload.data)
            ) {
                completion($0.mapError { .init($0) })
            }
        }
        
        func _makeSecretRequestJSON(
            completion: @escaping FormSessionKeyService.SecretRequestJSONCompletion
        ) {
            completion(.init(catching: makeSecretRequestJSON))
        }
        
        func _makeSessionKey(
            string: String,
            completion: @escaping FormSessionKeyService.MakeSessionKeyCompletion
        ) {
            completion(.init {
                
                try .init(sessionKeyValue: extractSharedSecret(string))
            })
        }
    }
}

// MARK: - Mappers

private extension CVVPINInitiateActivationService.GetCodeSuccess {
    
    init(_ response: GetProcessingSessionCodeService.Response) {
        
        self.init(
            code: .init(codeValue: response.code),
            phone: .init(phoneValue: response.phone)
        )
    }
}

private extension CVVPINInitiateActivationService.FormSessionKeySuccess {
    
    init(_ success: FormSessionKeyService.Success) {
        
        self.init(
            sessionKey: .init(sessionKeyValue: success.sessionKey.sessionKeyValue),
            eventID: .init(eventIDValue: success.eventID.eventIDValue),
            sessionTTL: success.sessionTTL
        )
    }
}

// MARK: - Error Mappers

private extension CVVPINInitiateActivationService.GetCodeResponseError {
    
    init(_ error: MappingRemoteServiceError<GetProcessingSessionCodeService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            switch mapResponseError {
                
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
                
            case .network:
                self = .network
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
            }
        }
    }
}

private extension CVVPINInitiateActivationService.FormSessionKeyError {
    
    init(_ error: FormSessionKeyService.Error) {
        
        switch error {
        case let .invalid(statusCode: statusCode, data: data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode: statusCode, errorMessage: errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case .serviceError:
            self = .serviceFailure
        }
    }
}

private extension FormSessionKeyService.APIError {
    
    init(_ error: MappingRemoteServiceError<FormSessionKeyService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}


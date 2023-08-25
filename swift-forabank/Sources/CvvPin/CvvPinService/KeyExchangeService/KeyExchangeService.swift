//
//  KeyExchangeService.swift
//
//
//  Created by Igor Malyarov on 20.07.2023.
//

import Foundation

public final class KeyExchangeService {
    
    public typealias ExtractSharedSecret = SharedSecretDomain.ExtractSharedSecret
    public typealias FormSessionKey = FormSessionKeyDomain.FormSessionKey
    public typealias MakeSecretRequest = KeyExchangeDomain.MakeSecretRequest
    
    private let extractSharedSecret: ExtractSharedSecret
    private let formSessionKey: FormSessionKey
    private let makeSecretRequest: MakeSecretRequest
    
    public init(
        makeSecretRequest: @escaping MakeSecretRequest,
        formSessionKey: @escaping FormSessionKey,
        extractSharedSecret: @escaping ExtractSharedSecret
    ) {
        self.makeSecretRequest = makeSecretRequest
        self.formSessionKey = formSessionKey
        self.extractSharedSecret = extractSharedSecret
    }
    
    public typealias KeyExchangeSessionCode = KeyExchangeDomain.SessionCode
    public typealias KeyExchangeCompletion = KeyExchangeDomain.Completion
    
    public func exchangeKey(
        with sessionCode: KeyExchangeSessionCode,
        completion: @escaping KeyExchangeCompletion
    ) {
        do {
            let secretRequest = try makeSecretRequest(sessionCode)
            handleSecretRequest(secretRequest.request, completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    private typealias SecretRequest = FormSessionKeyDomain.Request
    
    private func handleSecretRequest(
        _ secretRequest: SecretRequest,
        _ completion: @escaping KeyExchangeCompletion
    ) {
        formSessionKey(secretRequest) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
                
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(payload):
                
                handleFormSessionKeyResponse(payload.response, completion)
            }
        }
    }
    
    private func handleFormSessionKeyResponse(
        _ response: FormSessionKeyResponse,
        _ completion: @escaping KeyExchangeCompletion
    ) {
        extractSharedSecret(
            response.publicServerSessionKey
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(.init {
                
                try .init(
                    sharedSecret: result.get(),
                    eventID: .init(value: response.eventID),
                    sessionTTL: response.sessionTTL
                )
            })
        }
    }
}

// MARK: - Mappers

private extension KeyExchangeDomain.SecretRequest {
    
    var request: FormSessionKeyDomain.Request {
        
        .init(code: code.value, data: data)
    }
}

private extension FormSessionKeyDomain.Response {
    
    var response: FormSessionKeyResponse {
        
        .init(
            publicServerSessionKey: publicServerSessionKey.value,
            eventID: eventID.value,
            sessionTTL: sessionTTL
        )
    }
}

private struct FormSessionKeyResponse: Equatable {
    
    let publicServerSessionKey: String
    let eventID: String
    let sessionTTL: TimeInterval
    
    init(
        publicServerSessionKey: String,
        eventID: String,
        sessionTTL: TimeInterval
    ) {
        self.publicServerSessionKey = publicServerSessionKey
        self.eventID = eventID
        self.sessionTTL = sessionTTL
    }
}

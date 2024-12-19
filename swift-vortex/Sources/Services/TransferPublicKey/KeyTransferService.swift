//
//  KeyTransferService.swift
//  
//
//  Created by Igor Malyarov on 21.08.2023.
//

import Foundation

public final class KeyTransferService<OTP, EventID> {
    
    public typealias SwaddleKey = SwaddleKeyDomain<OTP>.SwaddleKey
    public typealias BindKey = BindKeyDomain<EventID>.BindKey
    
    private let swaddleKey: SwaddleKey
    private let bindKey: BindKey
    
    public init(
        swaddleKey: @escaping SwaddleKey,
        bindKey: @escaping BindKey
    ) {
        self.swaddleKey = swaddleKey
        self.bindKey = bindKey
    }
}

extension KeyTransferService {
    
    public typealias SharedSecret = SwaddleKeyDomain<OTP>.SharedSecret
    public typealias TransferCompletion = KeyTransferDomain.Completion
    
    public func transfer(
        otp: OTP,
        eventID: EventID,
        sharedSecret: SharedSecret,
        completion: @escaping TransferCompletion
    ) {
        swaddleKey(otp, sharedSecret) { [weak self] swaddleKeyResult in
            
            guard let self else { return }
            
            switch swaddleKeyResult {
            case let .failure(error):
                completion(.failure(.init(error: error, canRetry: false)))
                
            case let .success(data):
                let payload = BindKeyPayload(
                    eventID: eventID,
                    data: data
                )
                handleBindPayload(payload, with: completion)
            }
        }
    }
    
    private typealias BindKeyPayload = BindKeyDomain<EventID>.PublicKeyWithEventID
    
    private func handleBindPayload(
        _ payload: BindKeyPayload,
        with completion: @escaping TransferCompletion
    ) {
        bindKey(payload) { [weak self] bindResult in
            
            guard self != nil else { return }
            
            switch bindResult {
            case let .failure(error):
                completion(.failure(ErrorWithRetry(error)))
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

private extension ErrorWithRetry {
    
    init(_ errorWithRetryAttempts: ErrorWithRetryAttempts) {
        
        self.init(
            error: errorWithRetryAttempts.error,
            canRetry: errorWithRetryAttempts.retryAttempts > 0
        )
    }
}

//
//  KeyTransferService.swift
//  
//
//  Created by Igor Malyarov on 21.08.2023.
//

import Foundation

public final class KeyTransferService<OTP, EventID> {
    
    public typealias SwaddleKeyResult = Result<Data, Error>
    public typealias SwaddleKeyCompletion = (SwaddleKeyResult) -> Void
    public typealias SwaddleKey = (OTP, Data, @escaping SwaddleKeyCompletion) -> Void
    
    public typealias BindKeyResult = Result<Void, ErrorWithRetryAttempts>
    public typealias BindKeyCompletion = (BindKeyResult) -> Void
    public typealias BindKeyPayload = PublicKeyWithEventID<EventID>
    public typealias BindKey = (BindKeyPayload, @escaping BindKeyCompletion) -> Void
    
    private let swaddleKey: SwaddleKey
    private let bindKey: BindKey
    
    public init(
        swaddleKey: @escaping SwaddleKey,
        bindKey: @escaping BindKey
    ) {
        self.swaddleKey = swaddleKey
        self.bindKey = bindKey
    }
    
    public typealias TransferResult = Result<Void, ErrorWithRetry>
    public typealias TransferCompletion = (TransferResult) -> Void
    
    public func transfer(
        otp: OTP,
        eventID: EventID,
        keyData: Data,
        completion: @escaping TransferCompletion
    ) {
        swaddleKey(otp, keyData) { [weak self] swaddleKeyResult in
            
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

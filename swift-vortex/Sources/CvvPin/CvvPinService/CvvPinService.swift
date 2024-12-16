//
//  CvvPinService.swift
//
//
//  Created by Igor Malyarov on 16.07.2023.
//

import Foundation

public final class CvvPinService {
    
    // TODO: protect from race conditions
    private var state: State?
    
    private enum State {
        
        case error(Error)
        case keyExchange(KeyExchangeDomain.KeyExchange)
    }
    
    public typealias ExchangeKey = KeyExchangeDomain.ExchangeKey
    public typealias GetProcessingSessionCode = GetProcessingSessionCodeDomain.GetProcessingSessionCode
    public typealias TransferPublicKey = TransferPublicKeyDomain.TransferKey
    
    private let exchangeKey: ExchangeKey
    private let getProcessingSessionCode: GetProcessingSessionCode
    private let transferPublicKey: TransferPublicKey
    
    public init(
        getProcessingSessionCode: @escaping GetProcessingSessionCode,
        exchangeKey: @escaping ExchangeKey,
        transferPublicKey: @escaping TransferPublicKey
    ) {
        self.getProcessingSessionCode = getProcessingSessionCode
        self.exchangeKey = exchangeKey
        self.transferPublicKey = transferPublicKey
    }
}

// MARK: - Key Exchange

extension CvvPinService {
    
    public typealias Completion = (Result<Void, Error>) -> Void
    
    public func exchangeKey(completion: @escaping Completion) {
        
        exchangeKey { [unowned self] result in
            
            switch result {
            case let .failure(error):
                state = .error(error)
                completion(.failure(error))
                
            case let .success(keyExchange):
                state = .keyExchange(keyExchange)
                completion(.success(()))
            }
        }
    }
    
    internal typealias ExchangeKeyCompletion = KeyExchangeDomain.Completion
    
    internal func exchangeKey(
        completion: @escaping ExchangeKeyCompletion
    ) {
        getProcessingSessionCode { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
                
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(sessionCode):
                handleSessionCode(sessionCode.keyExchangeSessionCode, completion)
            }
        }
    }
    
    private typealias ExchangeKeySessionCode = KeyExchangeDomain.SessionCode
    
    private func handleSessionCode(
        _ sessionCode: ExchangeKeySessionCode,
        _ completion: @escaping ExchangeKeyCompletion
    ) {
        exchangeKey(sessionCode) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result)
        }
    }
}

// MARK: - Key Exchange Confirmation

extension CvvPinService {
    
    public typealias OTP = TransferPublicKeyDomain.OTP
    public typealias ConfirmExchangeResult = TransferPublicKeyDomain.Result
    
    public func confirmExchange(
        withOTP otp: OTP,
        _ completion: @escaping (ConfirmExchangeResult) -> Void
    ) {
        switch state {
        case .none:
            completion(.failure(ExchangeStateError()))
            
        case let .error(error):
            completion(.failure(error))
            
        case let .keyExchange(keyExchange):
            confirmExchange(
                withOTP: otp,
                keyExchange: keyExchange,
                completion: completion
            )
        }
    }
    
    public struct ExchangeStateError: Error {
        
        public init() {}
    }
    
    internal func confirmExchange(
        withOTP otp: OTP,
        keyExchange: KeyExchangeDomain.KeyExchange,
        completion: @escaping (ConfirmExchangeResult) -> Void
    ) {
        transferPublicKey(
            otp,
            keyExchange.eventID.exchangeEventID,
            keyExchange.secret
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result)
        }
    }
}

// MARK: - Mappers

private extension GetProcessingSessionCodeDomain.SessionCode {
    
    var keyExchangeSessionCode: KeyExchangeDomain.SessionCode {
        
        .init(value: value)
    }
}

private extension KeyExchangeDomain.KeyExchange {
    
    var secret: TransferPublicKeyDomain.SharedSecret {
        
        .init(sharedSecret.prefix(32))
    }
}

private extension KeyExchangeDomain.KeyExchange.EventID {
    
    var exchangeEventID: TransferPublicKeyDomain.EventID {
        
        .init(value: value)
    }
}

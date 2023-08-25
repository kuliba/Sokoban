//
//  KeyKeeper.swift
//  
//
//  Created by Igor Malyarov on 11.08.2023.
//

import Foundation

#warning("extract into separate module and decouple from CvvPinService")
public final class KeyKeeper {
    
    public typealias ConfirmExchange = TransferPublicKeyDomain.TransferKey
    public typealias ExchangeKey = (@escaping KeyExchangeDomain.Completion) -> Void
    
    private let _confirmExchange: ConfirmExchange
    private let _exchangeKey: ExchangeKey
    private var keyExchange: KeyExchangeDomain.KeyExchange?
    private let queue = DispatchQueue(label: "\(KeyKeeper.self)Queue")
    
    public init(
        exchangeKey: @escaping ExchangeKey,
        confirmExchange: @escaping ConfirmExchange
    ) {
        self._exchangeKey = exchangeKey
        self._confirmExchange = confirmExchange
    }
    
    #warning("more like get key: load key and loader could implement local loading with remote fallback stategy + store")
    public func exchangeKey() {
        
        _exchangeKey { [weak self] result in

            guard let self else { return }
            
            switch result {
            case let .failure(error):
                #warning("decide how to handle errors")
                print(error.localizedDescription)
                
            case let .success(keyExchange):
                queue.sync {
                    
                    self.keyExchange = keyExchange
                }
            }
        }
    }
    
    public func submitOTP(_ otp: String) {
        
        queue.async { [weak self] in
            
            guard let self, let keyExchange else { return }
            
            _confirmExchange(
                .init(value: otp),
                .init(value: keyExchange.eventID.value),
                .init(keyExchange.sharedSecret)
            ) { result in
                
                _ = result
            }
        }
    }
}


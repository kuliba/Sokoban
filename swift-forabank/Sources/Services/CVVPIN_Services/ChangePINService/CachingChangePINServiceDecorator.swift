//
//  CachingChangePINServiceDecorator.swift
//  
//
//  Created by Igor Malyarov on 25.10.2023.
//

import Foundation

public final class CachingChangePINServiceDecorator {
    
    public typealias Service = ChangePINService
    
    public typealias CacheCompletion = (Swift.Result<Void, Error>) -> Void
    public typealias Cache = (Service.OTPEventID, @escaping CacheCompletion) -> Void
    
    private let decoratee: ChangePINService
    private let cache: Cache
    
    public init(
        decoratee: ChangePINService,
        cache: @escaping Cache
    ) {
        self.decoratee = decoratee
        self.cache = cache
    }
}

public extension CachingChangePINServiceDecorator {
    
    func getPINConfirmationCode(
        completion: @escaping Service.GetPINConfirmationCodeCompletion
    ) {
        decoratee.getPINConfirmationCode { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(response):
                cache(response.otpEventID) { [weak self] result in
                    
                    guard self != nil else { return }
                    
                    switch result {
                    case .failure:
                        completion(.failure(.serviceError(.decryptionFailure)))
                        
                    case .success:
                        completion(.success(response))
                    }
                }
            }
        }
    }
}

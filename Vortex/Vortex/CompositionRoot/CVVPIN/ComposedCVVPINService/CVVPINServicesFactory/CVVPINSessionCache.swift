//
//  CVVPINSessionCache.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.11.2023.
//

import CVVPIN_Services
import Foundation

final class CVVPINSessionCache {
    
    typealias ActivateSuccess = CVVPINInitiateActivationService.ActivateSuccess
    
    typealias CacheCompletion = (Result<Void, Error>) -> Void
    typealias CacheSessionID = ((SessionID, Date), @escaping CacheCompletion) -> Void
    typealias CacheSessionKey = ((SessionKey, Date), @escaping CacheCompletion) -> Void
    
    typealias CurrentDate = () -> Date
    
    private let cacheSessionID: CacheSessionID
    private let cacheSessionKey: CacheSessionKey
    private let currentDate: CurrentDate
    
    init(
        cacheSessionID: @escaping CacheSessionID,
        cacheSessionKey: @escaping CacheSessionKey,
        currentDate: @escaping CurrentDate = Date.init
    ) {
        self.cacheSessionID = cacheSessionID
        self.cacheSessionKey = cacheSessionKey
        self.currentDate = currentDate
    }
}

extension CVVPINSessionCache {
    
    typealias ActivateResult = CVVPINInitiateActivationService.ActivateResult
    typealias ActivateCompletion = (ActivateResult) -> Void
    
    func handleActivateResult(
        _ result: ActivateResult,
        completion: @escaping ActivateCompletion
    ) {
        switch result {
        case let .failure(error):
            completion(.failure(error))
            
        case let .success(success):
            let sessionID = SessionID(sessionIDValue: success.eventID.eventIDValue)
            let sessionKey = SessionKey(sessionKeyValue: success.sessionKey.sessionKeyValue)
            let validUntil = currentDate() + .init(success.sessionTTL)
            
            _cacheSessionID(sessionID, sessionKey, validUntil, success, completion)
        }
    }
}

private extension CVVPINSessionCache {
    
    func _cacheSessionID(
        _ sessionID: SessionID,
        _ sessionKey: SessionKey,
        _ validUntil: Date,
        _ success: ActivateSuccess,
        _ completion: @escaping ActivateCompletion
    ) {
        cacheSessionID((sessionID, validUntil)) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(.serviceFailure))
                
            case .success:
                _cacheSessionKey(sessionKey, validUntil, success, completion)
            }
        }
    }
    
    func _cacheSessionKey(
        _ sessionKey: SessionKey,
        _ validUntil: Date,
        _ success: ActivateSuccess,
        _ completion: @escaping ActivateCompletion
    ) {
        cacheSessionKey((sessionKey, validUntil)) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case .failure:
                completion(.failure(.serviceFailure))
                
            case .success:
                completion(.success(success))
            }
        }
    }
}


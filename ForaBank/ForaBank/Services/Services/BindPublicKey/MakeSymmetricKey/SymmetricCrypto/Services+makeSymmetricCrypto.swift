//
//  Services+makeSymmetricCrypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2023.
//

import BindPublicKeyWithEventID
import CvvPin
import Foundation
import GenericRemoteService

extension Services {
    
    typealias SymmetricCrypto = CvvPin.SymmetricCrypto
    
    static func makeSymmetricCrypto(
        httpClient: HTTPClient
    ) -> SymmetricCrypto {
        
        let bindPublicKeyWithEventIDService = RemoteService(
            createRequest: RequestFactory.createBindPublicKeyWithEventIDRequest,
            performRequest: httpClient.performRequest,
            mapResponse: BindPublicKeyWithEventIDMapper.mapResponse
        )
        
        return FailingSymmetricCrypto(
            bindPublicKeyWithEventIDService: bindPublicKeyWithEventIDService
        )
    }
}

struct OK {}

private extension BindPublicKeyWithEventIDMapper {
    
    // adapter
    static func mapResponse(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Swift.Result<OK, Error> {
        
        if let error = map(data, response) {
            return .failure(error)
        } else {
            return .success(.init())
        }
    }
}

final class FailingSymmetricCrypto: SymmetricCrypto {
    
    typealias MapperError = BindPublicKeyWithEventIDMapper.Error
    typealias Result = Swift.Result<OK, MapperError>
    typealias BindPublicKeyWithEventIDService = CryptoAPIClient<PublicKeyWithEventID, Result>
    
    private let bindPublicKeyWithEventIDService: any BindPublicKeyWithEventIDService
    
    init(
        bindPublicKeyWithEventIDService: any BindPublicKeyWithEventIDService
    ) {
        self.bindPublicKeyWithEventIDService = bindPublicKeyWithEventIDService
    }
    
    func makeSymmetricKey(
        with payload: Payload,
        completion: @escaping SymmetricKeyCompletion
    ) {
        let publicKeyWithEventID = PublicKeyWithEventID(
            keyString: payload.publicServerSessionKey,
            eventID: .init(value: payload.eventID)
        )
        
        bindPublicKeyWithEventIDService.get(publicKeyWithEventID) { _ in
            
            let error = NSError(domain: "FailingSymmetricCrypto error", code: 0)
            completion(.failure(error))
        }
    }
}

//
//  Services+makeBindPublicKeyService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2023.
//

import CvvPin
import Foundation

extension Services {
    
    typealias BindPublicKeyService = CryptoAPIClient<APISymmetricKey, (SessionID, APISymmetricKey)>
    
    static func makeBindPublicKeyService(
    ) -> any BindPublicKeyService {
        
        FailingBindPublicKeyService()
    }
}

final class FailingBindPublicKeyService: CryptoAPIClient {
    
    typealias Response = (SessionID, APISymmetricKey)
    
    func get(
        _ request: APISymmetricKey,
        completion: @escaping Completion
    ) {
        completion(.failure(NSError(domain: "FailingBindPublicKeyService error", code: 0)))
    }
}

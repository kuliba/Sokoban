//
//  CVVPINComposer+checkActivation.swift
//  
//
//  Created by Igor Malyarov on 18.10.2023.
//

public extension CVVPINComposer {
    
    func checkActivation(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        infra.loadRSAKeyPair { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

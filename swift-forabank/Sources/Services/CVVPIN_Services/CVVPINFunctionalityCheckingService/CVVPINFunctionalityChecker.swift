//
//  CVVPINFunctionalityCheckingService.swift
//  
//
//  Created by Igor Malyarov on 20.10.2023.
//

public final class CVVPINFunctionalityCheckingService {
    
    public typealias LoadPublicKeyResult = Swift.Result<Void, Swift.Error>
    public typealias LoadPublicKeyCompletion = (LoadPublicKeyResult) -> Void
    public typealias LoadPublicKey = (@escaping LoadPublicKeyCompletion) -> Void
    
    private let loadValidPublicKey: LoadPublicKey
    
    public init(loadValidPublicKey: @escaping LoadPublicKey) {
        
        self.loadValidPublicKey = loadValidPublicKey
    }
}

public extension CVVPINFunctionalityCheckingService {
    
    typealias ActivateResult = Swift.Result<Void, Swift.Error>
    typealias ActivateCompletion = (ActivateResult) -> Void
    typealias Activate = (@escaping ActivateCompletion) -> Void
    
    typealias Result = Swift.Result<Void, Error>
    typealias Completion = (Result) -> Void
    
    func checkActivation(
        withFallback activate: @escaping Activate,
        completion: @escaping Completion
    ) {
        loadValidPublicKey { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                activateService(activate, completion)
                
            case .success:
                completion(.success(()))
            }
        }
    }
    
    enum Error: Swift.Error {
        
        case checkSessionFailure
    }
}

private extension CVVPINFunctionalityCheckingService {
    
    func activateService(
        _ activate: @escaping Activate,
        _ completion: @escaping Completion
    ) {
        activate { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result.mapError { _ in .checkSessionFailure })
        }
    }
}

//
//  SessionCodeLoaderWithFallback.swift
//  
//
//  Created by Igor Malyarov on 15.07.2023.
//

public final class SessionCodeLoaderWithFallback: SessionCodeLoader {
    
    private let primaryLoader: SessionCodeLoader
    private let fallbackLoader: SessionCodeLoader
    
    public init(
        primaryLoader: SessionCodeLoader,
        fallbackLoader: SessionCodeLoader
    ) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    public func load(completion: @escaping LoadCompletion) {
        
        primaryLoader.load { [weak self] primaryResult in
            
            guard let self else { return }
            
            switch primaryResult {
            case .failure:
                self.fallbackLoader.load { [weak self] fallbackResult in
                    
                    guard self != nil else { return }
                    
                    completion(fallbackResult)
                }
                
            case let .success(sessionCode):
                completion(.success(sessionCode))
            }
        }
    }
}

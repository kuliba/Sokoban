//
//  SessionCodeLoader+fallback.swift
//  
//
//  Created by Igor Malyarov on 15.07.2023.
//

public extension SessionCodeLoader {
    
    func fallback(
        to fallbackLoader: SessionCodeLoader
    ) -> SessionCodeLoaderWithFallback {
        
        SessionCodeLoaderWithFallback(
            primaryLoader: self,
            fallbackLoader: fallbackLoader
        )
    }
}

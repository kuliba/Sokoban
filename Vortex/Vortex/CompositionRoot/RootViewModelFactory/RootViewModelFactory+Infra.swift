//
//  RootViewModelFactory+Infra.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.01.2025.
//

extension RootViewModelFactory {
    
    struct Infra {
        
        let httpClient: HTTPClient
        let imageCache: ImageCache
        let generalImageCache: ImageCache
        let logger: LoggerAgentProtocol
    }
}

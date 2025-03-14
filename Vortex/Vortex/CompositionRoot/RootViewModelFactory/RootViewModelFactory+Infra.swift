//
//  RootViewModelFactory+Infra.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.01.2025.
//

import Foundation

extension RootViewModelFactory {
    
    struct Infra {
        
        let calendar: Calendar
        let currentDate: () -> Date
        let httpClient: HTTPClient
        let imageCache: ImageCache
        let logger: LoggerAgentProtocol
    }
}

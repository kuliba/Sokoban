//
//  RequestFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2023.
//

import Foundation

/// A namespace.
enum RequestFactory {}

extension RequestFactory {
    
    enum APIConfig {
        
#if RELEASE
        static let processingServerURL = "https://dmz-api-gate.forabank.ru"
#else
        static let processingServerURL = "https://dmz-api-gate-test.forabank.ru"
#endif
    }
}

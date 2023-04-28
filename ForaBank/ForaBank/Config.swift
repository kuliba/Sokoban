//
//  Config.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.03.2023.
//

import Foundation

enum Config {
    
    /// used in `AppDelegate`
    static let googleServiceInfoFileName: String = {
        
        #if DEBUG || MOCK
            "GoogleService-Info-test"
        #else
            "GoogleService-Info"
        #endif
    }()
    
    /// used in `Model` & `NotificationService`
    static let serverAgentEnvironment: ServerAgentEnvironment = {
        
        #if DEBUG
            .test
        #elseif MOCK
            .mock
        #else
            .prod
        #endif
    }()
    
    /// used in `URLHost`
    static let host: String = {
        
        #if DEBUG
            "pl.forabank.ru/dbo/api/v3"
        #elseif MOCK
            "http://10.1.206.85:8443"
        #else
            "bg.forabank.ru/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b"
        #endif
    }()
}

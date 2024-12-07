//
//  Config.swift
//  Vortex
//
//  Created by Igor Malyarov on 02.03.2023.
//

import Foundation

enum Config {
    
    static let domen = "businessinnovation.ru"
    static let name = "businessinnovation"
    static let primary = "bInnovation"
    static let telegram = "telegram"
    
    // "group.com.isimplelab.isimplemobile.\(Config.name)" TODO
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
        #elseif PREPROD
            .preprod
        #else
            .prod
        #endif
    }()
    
    /// used in `URLHost`
    static let host: String = {
        
        #if DEBUG
        "pl.\(Config.domen)/dbo/api/v3"
        #elseif MOCK
            "10.1.206.85:8443"
        #elseif PREPROD
            "pl.\(Config.domen)/preprod/dbo/api/v3"
        #else
            "bg.\(Config.domen)/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b"
        #endif
    }()
}

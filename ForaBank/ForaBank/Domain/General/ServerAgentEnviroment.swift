//
//  ServerAgentEnviroment.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 10.10.2022.
//

import Foundation


enum ServerAgentEnvironment {
    
    case test
    case preprod
    case prod
    case mock
    
    var baseURL: String {
        
        switch self {
        case .test:
            return "https://pl.forabank.ru/dbo/api/v3"
            
        case .preprod:
            return "https://pl.forabank.ru/preprod/dbo/api/v3"
                
        case .prod:
            return "https://bg.forabank.ru/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b"
                
        case .mock:
            return "http://10.1.206.85:8443"
        }
    }
}

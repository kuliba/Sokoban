//
//  SessionAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 20.04.2022.
//

import Foundation
import Combine

protocol SessionAgentProtocol {
    
    var action: PassthroughSubject<Action, Never> { get }
    var sessionState: CurrentValueSubject<SessionState, Never> { get }
}

enum SessionAgentAction {
    
    enum App {
        
        struct Activated: Action {}
        
        struct Inactivated: Action {}
    }

    enum Session {
    
        enum Start {
        
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<SessionCredentials, Error>
            }
        }
        
        enum Timeout {
       
            struct Request: Action {}
            
            struct Response: Action {
                
                let result: Result<TimeInterval, Error>
            }
        }
        
        struct Extend: Action {}
        
        struct Terminate: Action {}
    }
    
    enum Event {
    
        struct Network: Action {}
        
        struct UserInteraction: Action {}
    }
}

//
//  ModelAction.swift
//  Vortex
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation

enum ModelAction {

    //TODO: remove after refactoring
    struct LoggedIn: Action {}
    
    //TODO: remove after refactoring
    struct LoggedOut: Action {}
    
    struct PresentAlert: Action {
        
        let message: String
    }
    
    enum App {
    
        struct Launched: Action {}
        
        struct Activated: Action {}
        
        struct Inactivated: Action {}
    }
}

//
//  Model+DeepLink.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 27.09.2022.
//

import Foundation

extension ModelAction {
    
    enum DeepLink {
        
        struct Set: Action {
            
            let type: DeepLinkType
        }
        
        struct Process: Action {
           
            let type: DeepLinkType
        }
        
        struct Clear: Action {}
    }
}

//MARK: - Handlers

extension Model {
 
    func handleDeepLinkSet(_ payload: ModelAction.DeepLink.Set) {

        if auth.value == .authorized {
            
            self.action.send(ModelAction.DeepLink.Process(type: payload.type))
            
        } else {
            
            deepLinkType = payload.type
        }
    }
    
    func handleDeepLinkClear() {
        
        deepLinkType = nil
    }
}

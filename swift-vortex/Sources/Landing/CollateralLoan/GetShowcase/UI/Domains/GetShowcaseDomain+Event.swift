//
//  GetShowcaseDomain+Event.swift
//  
//
//  Created by Valentin Ozerov on 26.12.2024.
//

import Foundation

extension GetShowcaseDomain {
    
    public enum Event<InformerPayload>: Equatable where InformerPayload: Equatable {
        
        case load
        case loaded(Showcase)
        case failure(Failure)
        
        public enum Failure: Equatable {
            
            case alert(String)
            case informer(InformerPayload)
        }

        case dismissFailure
    }
}

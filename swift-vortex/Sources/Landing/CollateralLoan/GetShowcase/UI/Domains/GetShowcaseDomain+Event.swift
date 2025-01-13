//
//  GetShowcaseDomain+Event.swift
//  
//
//  Created by Valentin Ozerov on 26.12.2024.
//

import Foundation

extension GetShowcaseDomain {
    
    public enum Event: Equatable {
        
        case load
        case loaded(Result)
    }
}

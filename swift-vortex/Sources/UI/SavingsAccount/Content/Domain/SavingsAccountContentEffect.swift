//
//  SavingsAccountContentEffect.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

public enum SavingsAccountContentEffect: Equatable {
    
    case dismissInformer
    case delayLoad(DispatchTimeInterval)
    case load
}

//
//  FlowHelpers.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import Foundation

enum Destination: Equatable {
    
    case prepayment(Prepayment)
    case services
}

extension Destination {
    
    enum Prepayment: Equatable {
        
        case failure
        case options(Options)
    }
}

extension Destination.Prepayment {
    
    struct Options: Equatable {
        
        var value: String
        
        init(_ value: String = UUID().uuidString) {
            
            self.value = value
        }
    }
}

enum PushEvent: Equatable {
    
    case push
}

enum UpdateEvent: Equatable {
    
    case update
}

enum PushEffect: Equatable {
    
    case push
}

enum UpdateEffect: Equatable {
    
    case update
}

func makeDestination(
    _ value: String = UUID().uuidString
) -> Destination {
    
    .prepayment(.options(.init(value)))
}

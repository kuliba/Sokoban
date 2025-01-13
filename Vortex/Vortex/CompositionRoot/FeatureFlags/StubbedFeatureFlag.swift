//
//  StubbedFeatureFlag.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2024.
//

import Tagged

enum StubbedFeatureFlag: Equatable {
    
    case active(Option)
    case inactive
    
    enum Option: Equatable {
        
        case live, stub
    }
}

extension Tagged where RawValue == StubbedFeatureFlag {
    
    var isActive: Bool {
        
        if case .active = rawValue { return true }
        return false
    }
    
    var isLive: Bool {
        
        if case .active(.live) = rawValue { return true }
        return false
    }
    
    var isStub: Bool {
        
        if case .active(.stub) = rawValue { return true }
        return false
    }
    
    static var inactive: Self { .init(.inactive) }
    static var live: Self { .init(.active(.live)) }
    static var stub: Self { .init(.active(.stub)) }
}

extension Tagged where RawValue == StubbedFeatureFlag {

    var optionOrStub: RawValue.Option {
        
        switch rawValue {
        case .active(.live): return .live
        default:             return .stub
        }
    }
}

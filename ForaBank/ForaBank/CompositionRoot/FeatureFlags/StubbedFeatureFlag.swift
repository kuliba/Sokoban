//
//  StubbedFeatureFlag.swift
//  ForaBank
//
//  Created by Igor Malyarov on 06.02.2024.
//

import Tagged

enum StubbedFeatureFlag {
    
    case active(Option)
    case inactive
    
    enum Option {
        
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
}

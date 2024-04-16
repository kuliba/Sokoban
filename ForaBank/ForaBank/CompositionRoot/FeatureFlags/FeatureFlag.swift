//
//  FeatureFlag.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.12.2023.
//

import Tagged

enum FeatureFlag {
    
    case active, inactive
}

extension Tagged where RawValue == FeatureFlag {
    
    var isActive: Bool { rawValue == .active }
}

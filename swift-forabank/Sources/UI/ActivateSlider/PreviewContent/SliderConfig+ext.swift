//
//  SliderConfig+ext.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

extension SliderConfig {
    
    static let `default`: Self = .init(
        notActivated: .notActivated,
        waiting: .waiting,
        activating: .activating,
        activated: .activated, 
        thumbIconColor: .gray,
        font: .footnote
    )
}


//
//  PanelButton.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.04.2024.
//

import SwiftUI

struct PanelButton {
    
    let event: () -> Void
    let config: Config
}

extension PanelButton {
    
    struct Config {
        
        let title: String
        let icon: Image?
        let subtitle: String?
    }
}

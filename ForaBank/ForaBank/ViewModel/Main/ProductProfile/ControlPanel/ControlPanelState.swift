//
//  ControlPanelState.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation

struct ControlPanelState {
    
    var buttons: [ControlPanelButtonDetails]
    
    init(buttons: [ControlPanelButtonDetails]) {
        self.buttons = buttons
    }
}

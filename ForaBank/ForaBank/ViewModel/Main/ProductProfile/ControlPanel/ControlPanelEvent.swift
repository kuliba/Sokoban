//
//  ControlPanelEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation

enum ControlPanelEvent {
    
    case controlButtonEvent(ControlButtonEvent)
    case updateState([ControlPanelButtonDetails])
}

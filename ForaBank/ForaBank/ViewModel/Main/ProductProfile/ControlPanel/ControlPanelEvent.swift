//
//  ControlPanelEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation

enum ControlPanelEvent: Equatable {
    
    case controlButtonEvent(ControlButtonEvent)
    case updateState([ControlPanelButtonDetails])
}

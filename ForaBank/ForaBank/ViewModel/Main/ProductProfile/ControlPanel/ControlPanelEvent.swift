//
//  ControlPanelEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import UIPrimitives
import SwiftUI

enum ControlPanelEvent {
    
    case controlButtonEvent(ControlButtonEvent)
    case updateState([ControlPanelButtonDetails])
    case alert(AlertEvent)
}

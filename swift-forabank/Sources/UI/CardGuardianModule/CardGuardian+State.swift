//
//  CardGuardian+State.swift
//
//
//  Created by Andryusina Nataly on 31.01.2024.
//

import Foundation
import SwiftUI
import Tagged
import RxViewModel

// optional
public extension CardGuardian {
    
    enum ButtonTapped: Equatable {
        
        case toggleLock
        case changePin
        case showOnMain
    }
}

struct CardGuardianState: Equatable {
    
    let buttons: [_Button]
    var event: CardGuardian.ButtonTapped?
    
    struct _Button: Hashable {
        
        let event: CardGuardian.ButtonTapped
        let title: String
        let iconType: CardGuardian.Config.IconType
        let subtitle: String?
    }
}

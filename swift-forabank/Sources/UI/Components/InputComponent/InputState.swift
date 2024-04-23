//
//  InputState.swift
//
//
//  Created by Дмитрий Савушкин on 04.03.2024.
//

import SwiftUI

struct InputState<Icon> {
    
    var dynamic: Dynamic
    let settings: Settings
}

extension InputState {
    
    struct Dynamic: Equatable {
        
        var value: String
        var warning: String?
    }
    
    struct Settings {
        
        let hint: String?
        let icon: Icon
        let keyboard: Keyboard
        let title: String
        let subtitle: String
    }
}

extension InputState.Settings {
    
    enum Keyboard: Equatable {
        
        case `default`, numeric
    }
}

extension InputState: Equatable where Icon: Equatable {}
extension InputState.Settings: Equatable where Icon: Equatable {}

//
//  InputState.swift
//
//
//  Created by Дмитрий Савушкин on 04.03.2024.
//

import SwiftUI

public struct InputState<Icon> {
    
    var dynamic: Dynamic
    let settings: Settings
    
    public init(
        dynamic: InputState<Icon>.Dynamic,
        settings: InputState<Icon>.Settings
    ) {
        self.dynamic = dynamic
        self.settings = settings
    }
}

public extension InputState {
    
    struct Dynamic: Equatable {
        
        var value: String
        var warning: String?
        
        public init(
            value: String,
            warning: String? = nil
        ) {
            self.value = value
            self.warning = warning
        }
    }
    
    struct Settings {
        
        let hint: String?
        let icon: Icon
        let keyboard: Keyboard
        let title: String
        let subtitle: String?
        
        public init(
            hint: String? = nil,
            icon: Icon,
            keyboard: InputState<Icon>.Settings.Keyboard,
            title: String,
            subtitle: String?
        ) {
            self.hint = hint
            self.icon = icon
            self.keyboard = keyboard
            self.title = title
            self.subtitle = subtitle
        }
    }
}

public extension InputState.Settings {
    
    enum Keyboard: Equatable {
        
        case `default`, numeric
    }
}

extension InputState: Equatable where Icon: Equatable {}
extension InputState.Settings: Equatable where Icon: Equatable {}

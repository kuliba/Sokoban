//
//  InputState.swift
//
//
//  Created by Дмитрий Савушкин on 04.03.2024.
//

import SwiftUI

public struct InputState<Icon> {
    
    public var dynamic: Dynamic
    public let settings: Settings
    
    public init(
        dynamic: Dynamic,
        settings: Settings
    ) {
        self.dynamic = dynamic
        self.settings = settings
    }
}

extension InputState {
    
    public struct Dynamic: Equatable {
        
        public var value: String
        public var warning: String?
        
        public init(
            value: String,
            warning: String? = nil
        ) {
            self.value = value
            self.warning = warning
        }
    }
    
    public struct Settings {
        
        public let hint: String?
        public let icon: Icon
        public let keyboard: Keyboard
        public let title: String
        public let subtitle: String?
        
        public init(
            hint: String? = nil,
            icon: Icon,
            keyboard: Keyboard,
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

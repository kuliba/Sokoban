//
//  AlertModelOfVoid.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.02.2025.
//

import SwiftUI
import UIPrimitives

typealias AlertModelOfVoid = AlertModelOf<() -> Void>

extension AlertModelOfVoid {
    
    init(
        title: String,
        message: String?,
        dismiss: @escaping () -> Void
    ) {
        self.init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: dismiss
            )
        )
    }
    
    static func error(
        alert: StringAlert?,
        dismiss: @escaping () -> Void
    ) -> Self {
        
        return .init(
            title: "Ошибка",
            message: alert?.message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: dismiss
            )
        )
    }
    
    static func error(
        message: String?,
        dismiss: @escaping () -> Void
    ) -> Self {
        
        return .init(
            title: "Ошибка",
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: dismiss
            )
        )
    }
}

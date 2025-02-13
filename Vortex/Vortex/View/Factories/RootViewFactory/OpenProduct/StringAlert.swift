//
//  StringAlert.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.02.2025.
//

import SwiftUI

struct StringAlert: Identifiable {
    
    let message: String
    
    var id: Int { message.hashValue }
    
    func error(
        dismiss: @escaping () -> Void
    ) -> SwiftUI.Alert {
        
        return alert(title: .init("Ошибка"), dismiss: dismiss)
    }
    
    func alert(
        title: String,
        dismiss: @escaping () -> Void
    ) -> SwiftUI.Alert {
        
        return .init(
            title: .init(title),
            message: .init(message),
            dismissButton: .default(.init("OK"), action: dismiss)
        )
    }
}

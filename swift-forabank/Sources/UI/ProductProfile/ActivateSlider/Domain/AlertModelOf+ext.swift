//
//  AlertModelOf+ext.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import UIPrimitives
import Foundation

extension AlertModelOf<CardActivateEvent> {
    
    public typealias ActivatePayload = Int

    static func activateAlert(_ payload: ActivatePayload) -> AlertModelOf {
        
        .init(
            id: .default,
            title: "Активировать карту?",
            message: "После активации карта будет готова к использованию",
            primaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: CardActivateEvent.card(.confirmActivate(.cancel))
            ),
            secondaryButton: .init(
                type: .default,
                title: "ОК",
                event: CardActivateEvent.card(.confirmActivate(.activate(payload)))
            )
        )
    }
}

private extension UUID {
    
    static let `default`: UUID = UUID(uuidString: "68b696d7-320b-4402-a412-d9cee10fc6a3")!
}

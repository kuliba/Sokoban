//
//  AlertModelOf+ext.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import UIPrimitives

extension AlertModelOf<CardActivateEvent> {
    
    static func activateAlert() -> AlertModelOf {
        
        .init(
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
                event: CardActivateEvent.card(.confirmActivate(.activate))
            )
        )
    }
}

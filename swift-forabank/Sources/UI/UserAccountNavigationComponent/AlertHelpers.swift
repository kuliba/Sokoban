//
//  AlertHelpers.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 27.01.2024.
//

import UIPrimitives

public extension AlertModel
where PrimaryEvent == UserAccountNavigation.Event,
      SecondaryEvent == UserAccountNavigation.Event {
    
    private static func `default`(
        title: String,
        message: String?,
        primaryEvent: PrimaryEvent,
        secondaryEvent: SecondaryEvent? = nil
    ) -> Self {
        
        .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: primaryEvent
            ),
            secondaryButton: secondaryEvent.map {
                
                .init(
                    type: .cancel,
                    title: "Отмена",
                    event: $0
                )
            }
        )
    }
    
    static func error(
        message: String? = nil,
        event: PrimaryEvent
    ) -> Self {
        
        .default(
            title: "Ошибка",
            message: message,
            primaryEvent: event
        )
    }
    
    static func missingContract(
        event: PrimaryEvent
    ) -> Self {
        
        .default(
            title: "Включите переводы СБП",
            message: "Для подключения СБП переведите ползунок в состояние – ВКЛ.\nПосле этого вы сможете отправлять и получать переводы СБП.",
            primaryEvent: event
        )
    }
    
    static func missingProduct(
        event: PrimaryEvent
    ) -> Self {
        
        .default(
            title: "Сервис не доступен",
            message: "Для подключения договора СБП у Вас должен быть подходящий продукт",
            primaryEvent: event
        )
    }
    
    static func setBankDefault(
        event: PrimaryEvent,
        secondaryEvent: SecondaryEvent
    ) -> Self {
        
        .default(
            title: "Внимание",
            message: "Фора-банк будет выбран банком по умолчанию",
            primaryEvent: event,
            secondaryEvent: secondaryEvent
        )
    }
    
    static func tryAgainFPSAlert(
        _ event: PrimaryEvent
    ) -> Self {
        
        let message = "Превышено время ожидания. Попробуйте позже"
        
        return .error(message: message, event: event)
    }
}

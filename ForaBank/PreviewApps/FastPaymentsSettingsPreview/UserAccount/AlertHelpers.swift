//
//  AlertHelpers.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 27.01.2024.
//

import UIPrimitives

extension AlertModel
where PrimaryEvent == UserAccountViewModel.Event,
      SecondaryEvent == UserAccountViewModel.Event {
    
    static func `default`(
        title: String,
        message: String,
        primaryEvent: PrimaryEvent,
        secondaryEvent: SecondaryEvent
    ) -> Self {
        
        .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: primaryEvent
            ),
            secondaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: secondaryEvent
            )
        )
    }
    
    static func error(
        message: String? = nil,
        event: PrimaryEvent
    ) -> Self {
        
        .ok(
            title: "Ошибка",
            message: message,
            event: event
        )
    }
    
    static func ok(
        title: String = "",
        message: String? = nil,
        event: PrimaryEvent
    ) -> Self {
        
        self.init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: event
            )
        )
    }
    
    static func missingContract(
        event: PrimaryEvent
    ) -> Self {
        
        .ok(
            title: "Не найден договор СБП",
            message: "Договор будет создан автоматически, если Вы включите переводы через СБП",
            event: event
        )
    }
    
    static func missingProduct(
        event: PrimaryEvent
    ) -> Self {
        
        .ok(
            title: "Сервис не доступен",
            message: "Для подключения договора СБП у Вас должен быть подходящий продукт",
            event: event
        )
    }
    
    static func setBankDefault(
        primaryEvent: PrimaryEvent,
        secondaryEvent: SecondaryEvent
    ) -> Self {
        
        .default(
            title: "Внимание",
            message: "Фора-банк будет выбран банком по умолчанию",
            primaryEvent: primaryEvent,
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

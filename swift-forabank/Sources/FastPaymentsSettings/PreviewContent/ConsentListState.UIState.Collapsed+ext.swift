//
//  ConsentListState.UIState.Collapsed+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

public extension ConsentListState.UIState.Collapsed {
    
    static let empty: Self = .init(bankNames: [])
    
    static let one: Self = .init(
        bankNames: ["Сбербанк"]
    )
    
    static let two: Self = .init(
        bankNames: ["Сбербанк", "Альфа-банк"]
    )
    
    static let preview: Self = .init(
        bankNames: ["Сбербанк", "Альфа-банк", "ВТБ", "Тинькофф банк", "Открытие", "Сургутнефтегазбанк"]
    )
}

//
//  [Bank]+ext.swift
//
//
//  Created by Igor Malyarov on 13.01.2024.
//

public extension Array where Element == Bank {
    
    static let preview: Self = ["Сбербанк", "Альфа-банк", "ВТБ", "Тинькофф банк", "Открытие", "Сургутнефтегазбанк"].map {
        
        .init(id: .init($0.lowercased()), name: $0)
    }
    
    static let many: Self = [
        .init(id: "100000000001", name: "Газпромбанк"),
        .init(id: "100000000002", name: "РНКО Платежный центр"),
        .init(id: "100000000003", name: "СКБ-банк"),
        .init(id: "100000000004", name: "Тинькофф Банк"),
        .init(id: "100000000005", name: "ВТБ Банк"),
        .init(id: "100000000006", name: "АК БАРС БАНК"),
        .init(id: "100000000008", name: "Альфа-Банк"),
        .init(id: "100000000009", name: "QIWI Банк"),
        .init(id: "100000000013", name: "Совкомбанк"),
        .init(id: "100000000015", name: "Банк ФК Открытие"),
        .init(id: "100000000017", name: "МТС Банк"),
        .init(id: "100000000018", name: "ОТП БАНК"),
        .init(id: "100000000020", name: "РОССЕЛЬХОЗБАНК"),
        .init(id: "100000000025", name: "МОСКОВСКИЙ КРЕДИТНЫЙ БАНК"),
        .init(id: "100000000026", name: "ПАО Банк Уралсиб"),
        .init(id: "100000000031", name: "Уральский банк реконструкции и развития"),
        .init(id: "100000000036", name: "СМП Банк"),
        .init(id: "100000000041", name: "БКС Банк"),
        .init(id: "100000000043", name: "Газэнергобанк"),
        .init(id: "100000000046", name: "Металлинвестбанк"),
    ]
}

private extension Bank {
    
    init(id: Bank.BankID, name: String) {
        
        self.init(id: id, name: name, image: .init(systemName: "building.columns"))
    }
}

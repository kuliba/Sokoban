//
//  AuthProductsViewModel+Preview.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 15.02.2022.
//

import SwiftUI

extension AuthProductsViewModel {
    
    static let mockData: AuthProductsViewModel = AuthProductsViewModel(productCards: AuthProductsViewModel.sampleProducts)
    
    static let sampleProducts: [ProductCard] = [
        
        ProductCard(style: .light,
                    title: "Карта «Миг»",
                    subtitle: ["Получите карту с кешбэком в любом офисе без предварительного заказа!"],
                    image: .image(Image("icCardMir")),
                    infoButton: .init(url: URL(string: "https://www.forabank.ru/private/cards/")!),
                    orderButton: .init(url: URL(string: "https://www.forabank.ru/private/cards/")!)),

        ProductCard(style: .dark,
                    title: "Пакет «Премиальный»",
                    subtitle: ["• Личный помощник 24/7", "• Самые выгодные условия кэшбэка", "• Особые курсы обмена валют","• Комфорт бизнес-класса в путешествиях"],
                    image: .endpoint("test"),
                    infoButton: .init(url: URL(string: "https://www.forabank.ru/private/cards/")!),
                    orderButton: .init(url: URL(string: "https://www.forabank.ru/private/cards/")!)),

        ProductCard(style: .light,
                    title: "Все включено",
                    subtitle: ["• Кэшбэк до 20%","• До 5,5% годовых на остаток по счёту", "• Стоимость обслуживания от 0 ₽ в месяц"],
                    image: .image(Image("icCardMir")),
                    infoButton: .init(url: URL(string: "https://www.forabank.ru/private/cards/")!),
                    orderButton: .init(url: URL(string: "https://www.forabank.ru/private/cards/")!))
    ]
}

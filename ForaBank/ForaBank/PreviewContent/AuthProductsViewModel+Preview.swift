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
        
        ProductCard(id: 0,
                    style: .light,
                    title: "Карта «Миг»",
                    subtitle: "Получите карту с кешбэком в любом офисе без предварительного заказа!",
                    image: Image("icCardMir"),
                    infoButton: .init(action: {}),
                    orderButton: .init(action: {})),

        ProductCard(id: 1,
                    style: .dark,
                    title: "Пакет «Премиальный»",
                    subtitle: "• Личный помощник 24/7 \n• Самые выгодные условия кэшбэка \n• Особые курсы обмена валют \n• Комфорт бизнес-класса в путешествиях",
                    image: Image("icCardMir"),
                    infoButton: .init(action: {}),
                    orderButton: .init(action: {})),

        ProductCard(id: 2,
                    style: .light,
                    title: "Все включено",
                    subtitle: "• Кэшбэк до 20% \n• До 5,5% годовых на остаток по счёту \n• Стоимость обслуживания от 0 ₽ в месяц",
                    image: Image("icCardMir"),
                    infoButton: .init(action: {}),
                    orderButton: .init(action: {}))
    ]
}

//
//  Mock.swift
//  ForaBank
//
//  Created by Mikhail on 01.06.2021.
//

import UIKit

class MockItems {

    class func orderProducts() -> [OrderProductModel] {
        return [OrderProductModel(image: "cover1",
                                  title: "Карта «Миг»",
                                  subtitle: "Получите карту с кэшбеком в любом офисе без предварительного заказа",
                                  url: "https://www.forabank.ru/private/cards/karta-mig/",
                                  color: .white),
                OrderProductModel(image: "cover2",
                                  title: "Все включено",
                                  subtitle: "Признана лучшей дебетовой картой по версии маркетплейса «Выбери.ру» в октябре 2020 г.",
                                  url: "https://www.forabank.ru/private/cards/vsye-vklyucheno/"),
                OrderProductModel(image: "cover3",
                                  title: "Пакет «Премиальный»",
                                  subtitle: "• Отличные условия\n• Без очередей\n• Поддержка 24/7\n• Пакет услуг",
                                  url: "https://www.forabank.ru/lendingi/premialnoe-obsluzhivanie/")]
    }
    
}

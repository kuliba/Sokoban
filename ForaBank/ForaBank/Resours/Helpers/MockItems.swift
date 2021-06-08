//
//  Mock.swift
//  ForaBank
//
//  Created by Mikhail on 01.06.2021.
//

import UIKit

class MockItems {

    /// Данные для заполнения экрана OrderProductsViewController
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
    
    /// Данные для заполнения экрана PaymentsController,
    /// каждый элемент имеет имя для отображения, ссылку на иконку,
    /// имя контроллера для перехода, описание или коючевые слова для поиска по элементам меню
    
    /// Данные для заполнения экрана PaymentsController в верхней секции
    class func returnPayments() -> [PaymentsModel] {
        return [
            PaymentsModel(id: 1, name: "Оплата \nпо QR",
                          iconName: "PaymentsIconBarcode-scanner",
                          avatarImageName: nil,
                          controllerName: "DevelopViewController",
                          description: "QR"),
            
            PaymentsModel(id: 2, name: "Шаблоны и\nавтоплатежи",
                          iconName: "PaymentsIconFavorites",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 3, name: "Перевод по\nтелефону",
                          iconName: "PaymentsIconPhone",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 4, name: "Любимая Beeline",
//                          iconName: "bilane",
                          avatarImageName: "bilane",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 5, name: "Обмен валют",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
        ]
    }
    
    /// Данные для заполнения экрана PaymentsController в средней секции
    class func returnTransfers() -> [PaymentsModel] {
        return [
            PaymentsModel(id: 6, name: "Между своими",
                          iconName: "PaymentsIconMyPay",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 7, name: "По номеру телефона",
                          iconName: "PaymentsIconPhonePay",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 8, name: "За рубеж",
                          iconName: "PaymentsIconWarldPay",
                          controllerName: "ChooseCountryTableViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 9, name: "На другую карту",
                          iconName: "PaymentsIconCardPay",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 10, name: "По реквизитaм",
                          iconName: "PaymentsIconReqPay",
                          controllerName: "DevelopViewController",
                          description: "Что то")
            
        ]
    }
    
    /// Данные для заполнения экрана PaymentsController в нижней секции
    class func returnPay() -> [PaymentsModel] {
        return [
            PaymentsModel(id: 11, name: "Оплата по QR",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "DevelopViewController",
                          description: "QR"),
            
            PaymentsModel(id: 12, name: "Мобильная связь",
                          iconName: "PaymentsIconPhone",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 13, name: "Коммунальные услуги ЖКХ",
                          iconName: "PaymentsIconLamp",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 14, name: "Интернет, телевидение, телефон",
                          iconName: "PaymentsIconComputer",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 15, name: "Штрафы, налоги и государственные услуги",
                          iconName: "PaymentsIconCourt",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 16, name: "Социальные сети, онлайн игры карты",
                          iconName: "PaymentsIconGamepad",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 17, name: "В бюджет РФ",
                          iconName: "PaymentsIconBlazon",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 18, name: "Охранные системы",
                          iconName: "PaymentsIconKey",
                          controllerName: "DevelopViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 19, name: "Прочее",
                          iconName: "PaymentsIconShop",
                          controllerName: "DevelopViewController",
                          description: "Что то")
        ]
    }
    
    
}

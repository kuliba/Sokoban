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
//            PaymentsModel(id: 1, name: "Оплата \nпо QR",
//                          iconName: "PaymentsIconBarcode-scanner",
//                          avatarImageName: nil,
//                          controllerName: "DevelopViewController",
//                          description: "QR"),
            
            PaymentsModel(id: 2, name: "Шаблоны и\nавтоплатежи",
                          iconName: "star",
                          controllerName: ""),
            
//            PaymentsModel(id: 3, name: "Перевод по\nтелефону",
//                          iconName: "PaymentsIconPhone",
//                          controllerName: "DevelopViewController",
//                          description: "Что то"),
//
//            PaymentsModel(id: 4, name: "Любимая Beeline",
////                          iconName: "bilane",
//                          avatarImageName: "bilane",
//                          controllerName: "DevelopViewController",
//                          description: "Что то"),
//
//            PaymentsModel(id: 5, name: "Обмен валют",
//                          iconName: "PaymentsIconCarancy",
//                          controllerName: "DevelopViewController",
//                          description: "Что то"),
            
        ]
    }
    
    /// Данные для заполнения экрана PaymentsController в средней секции
    class func returnTransfers() -> [PaymentsModel] {
        return [
            
            PaymentsModel(id: 7, name: "По номеру телефона",
                          iconName: "PaymentsIconPhonePay",
                          controllerName: "ContactsViewController",
                          description: ""),
            PaymentsModel(id: 6, name: "Между счетами",
                          iconName: "PaymentsIconMyPay",
                          controllerName: "DevelopViewController",
                          description: ""),
            
            PaymentsModel(id: 8, name: "За рубеж",
                          iconName: "PaymentsIconWarldPay",
                          controllerName: "ChooseCountryTableViewController",
                          description: ""),
            
            PaymentsModel(id: 9, name: "На другую карту",
                          iconName: "PaymentsIconCardPay",
                          controllerName: "DevelopViewController",
                          description: ""),
            
            PaymentsModel(id: 10, name: "По реквизитaм",
                          iconName: "PaymentsIconReqPay",
                          controllerName: "TransferByRequisitesViewController",
                          description: "")
            
        ]
    }
    

    class func returnOpenProduct() -> [PaymentsModel] {
        return [
            PaymentsModel(id: 99, name: "Карту",
                          iconName: "openCard",
                          controllerName: "https://promo.forabank.ru/?metka=leads1&affiliate_id=44935&source=leads1&transaction_id=6dae603673619b0681e492d4bd1d8f3a",
                          description: "Все включено"),
            
            PaymentsModel(id: 98, name: "Вклад",
                          iconName: "openDeposit",
                          controllerName: "https://www.forabank.ru/private/deposits/",
                          description: "8% годовых"),
            
            PaymentsModel(id: 97, name: "Кредит",
                          iconName: "loanIcon",
                          controllerName: "https://www.forabank.ru/private/credits/",
                          description: "от 7% годовых"),
            
            PaymentsModel(id: 96, name: "Счет",
                          iconName: "openAccount",
                          controllerName: "https://www.forabank.ru/business/credits/investitsii/?sphrase_id=26274",
                          description: "₽  $  €"),
            
            PaymentsModel(id: 95, name: "Страховку",
                          iconName: "shieldMain",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: "Для себя")
            
        ]
    }
    
    /// Данные для заполнения экрана PaymentsController в нижней секции
    class func returnPay() -> [PaymentsModel] {
        return [
            PaymentsModel(id: 11, name: "Оплата по QR",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "",
                          description: "QR"),
            
            PaymentsModel(id: 12, name: "Мобильная связь",
                          iconName: "smartphoneblack",
                          controllerName: "MobilePayViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 13, name: "Услуги ЖКХ",
                          iconName: "iconLampNew",
                          controllerName: "GKHMainViewController",
                          description: "ЖКХ"),
            
            PaymentsModel(id: 14, name: "Интернет, ТВ",
                          iconName: "tv",
                          controllerName: "",
                          description: "Что то"),
            
            PaymentsModel(id: 15, name: "Штрафы",
                          iconName: "carMain",
                          controllerName: "",
                          description: "Что то"),
            
            PaymentsModel(id: 16, name: "Соцсети, игры, карты",
                          iconName: "iconGame",
                          controllerName: "",
                          description: "Что то"),
            
            PaymentsModel(id: 17, name: "Госуслуги",
                          iconName: "PaymentsIconBlazon",
                          controllerName: "",
                          description: "Что то"),
            
            PaymentsModel(id: 18, name: "Охранные системы",
                          iconName: "key",
                          controllerName: "",
                          description: "Что то"),
            
            PaymentsModel(id: 19, name: "Прочее",
                          iconName: "shopping-cart",
                          controllerName: "MeToMeViewController",
                          description: "Что то")
        ]
    }
    
    //Для заполнения быстрых действий главный экран
    /// Данные для заполнения экрана PaymentsController в нижней секции
    class func returnFastPay() -> [PaymentsModel] {
        return [
            PaymentsModel(id: 80, name: "Оплата по QR",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "QRViewController",
                          description: "QR"),
            
            PaymentsModel(id: 81, name: "Перевод по номеру",
                          iconName: "smartphone",
                          controllerName: "ContactsViewController",
                          description: "Что то"),
            
            PaymentsModel(id: 82, name: "Шаблоны и автоплатежи",
                          iconName: "star",
                          controllerName: "GKHMainViewController",
                          description: "ЖКХ"),
            
            PaymentsModel(id: 83, name: "Мой дом",
                          iconName: "home",
                          controllerName: "",
                          description: "Что то"),
            
            PaymentsModel(id: 84, name: "Госуслуги",
                          iconName: "PaymentsIconBlazon",
                          controllerName: "",
                          description: "Что то")
        ]
    }
    

    class func returnBanner() -> [PaymentsModel] {
        return [
//            PaymentsModel(id: 1, name: "Оплата \nпо QR",
//                          iconName: "PaymentsIconBarcode-scanner",
//                          avatarImageName: nil,
//                          controllerName: "DevelopViewController",
//                          description: "QR"),
            
            PaymentsModel(id: 22, name: "Шаблоны и\nавтоплатежи",
                          iconName: "bannerContact",
                          controllerName: "https://promo7.forabank.ru/?metka=kontakt_krpst1"),
            
            PaymentsModel(id: 33, name: "Перевод по\nтелефону",
                          iconName: "autocash",
                          controllerName: "https://www.forabank.ru/private/cards/sezonnoe-predlozhenie/",
                          description: "Что то"),
//
//            PaymentsModel(id: 4, name: "Любимая Beeline",
////                          iconName: "bilane",
//                          avatarImageName: "bilane",
//                          controllerName: "DevelopViewController",
//                          description: "Что то"),
//
//            PaymentsModel(id: 5, name: "Обмен валют",
//                          iconName: "PaymentsIconCarancy",
//                          controllerName: "DevelopViewController",
//                          description: "Что то"),
            
        ]
    }
    class func returnCurrency() -> [PaymentsModel] {
        return [
//            PaymentsModel(id: 1, name: "Оплата \nпо QR",
//                          iconName: "PaymentsIconBarcode-scanner",
//                          avatarImageName: nil,
//                          controllerName: "DevelopViewController",
//                          description: "QR"),
            
            PaymentsModel(id: 2, name: "Шаблоны и\nавтоплатежи",
                          iconName: "promoBanner2",
                          controllerName: "")
//
//            PaymentsModel(id: 5, name: "Обмен валют",
//                          iconName: "PaymentsIconCarancy",
//                          controllerName: "DevelopViewController",
//                          description: "Что то"),
            
        ]
    }
    
    class func returnSectionInProducts() -> [PaymentsModel] {
        return [
            PaymentsModel(id: 1, name: "Неактивированные продукты",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "https://www.forabank.ru/private/cards/",
                          description: "QR"),
            PaymentsModel(id: 1, name: "Карты и счета",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "https://www.forabank.ru/private/cards/",
                          description: "QR"),
            
            PaymentsModel(id: 2, name: "Вклады",
                          iconName: "promoBanner2",
                          controllerName: "https://www.forabank.ru/private/deposits/"),
//
            PaymentsModel(id: 5, name: "Кредиты",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/credits/",
                          description: "Что то"),
            
            PaymentsModel(id: 5, name: "Инвестиции",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/business/credits/investitsii/?sphrase_id=26274",
                          description: "Что то"),
            
            PaymentsModel(id: 5, name: "Страховка",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: "Что то"),
            PaymentsModel(id: 5, name: "Заблокированные продукты",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: "Что то")
        ]
    }
    
    class func returnsRequisits() -> [PaymentsModel] {
        return [
            PaymentsModel(id: 1, name: "Получатель",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "https://www.forabank.ru/private/cards/",
                          description: ""),
            
            PaymentsModel(id: 2, name: "Номер счета",
                          iconName: "promoBanner2",
                          controllerName: "https://www.forabank.ru/private/deposits/",
                        description: ""),
            
            PaymentsModel(id: 5, name: "БИК",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/credits/",
                          description: ""),
            
            PaymentsModel(id: 5, name: "Кореспондентский счет",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/business/credits/investitsii/?sphrase_id=26274",
                          description: ""),
            
            PaymentsModel(id: 5, name: "ИНН",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(id: 5, name: "КПП",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(id: 5, name: "Держатель карты",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(id: 5, name: "Номер карты",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(id: 5, name: "Карта действует до",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: "")
        ]
    }
    
    class func returnsDepositInfo() -> [PaymentsModel] {
        return [
            PaymentsModel(id: 1, name: "Сумма первоначального размещения",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "https://www.forabank.ru/private/cards/",
                          description: ""),
            
            PaymentsModel(id: 2, name: "Дата открытия ",
                          iconName: "promoBanner2",
                          controllerName: "https://www.forabank.ru/private/deposits/",
                        description: ""),
            
            PaymentsModel(id: 5, name: "Дата закрытия",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/credits/",
                          description: ""),
            
            PaymentsModel(id: 5, name: "Срок вклада",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/business/credits/investitsii/?sphrase_id=26274",
                          description: ""),
            
            PaymentsModel(id: 5, name: "Ставка по вкладу",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(id: 5, name: "Дата следующего начисления процентов",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(id: 5, name: "Сумма выплаченных процентов всего",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(id: 5, name: "Суммы пополнений",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(id: 6, name: "Суммы списаний",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(id: 7, name: "Сумма начисленных процентов на дату",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: "")
        ]
    }
    
    class func butttonArray() -> [PaymentsModel] {
        return [
            PaymentsModel(id: 1, name: "+ Шаблон",
                          iconName: "star24size",
                          controllerName: "https://www.forabank.ru/private/cards/",
                          description: "QR"),
            
            PaymentsModel(id: 2, name: "Документ",
                          iconName: "doc",
                          controllerName: "https://www.forabank.ru/private/deposits/",
                        description: "Что то"),
            
            PaymentsModel(id: 5, name: "Детали",
                          iconName: "info.circle",
                          controllerName: "https://www.forabank.ru/private/credits/",
                          description: "Что то"),
                    
        ]
    }
    
    class func returnDetails() -> [PaymentsModel] {
        return [
//            PaymentsModel(id: 1, name: "Оплата \nпо QR",
//                          iconName: "PaymentsIconBarcode-scanner",
//                          avatarImageName: nil,
//                          controllerName: "DevelopViewController",
//                          description: "QR"),
            
            PaymentsModel(id: 1, name: "Название",
                          iconName: "",
                          controllerName: ""),
            
            PaymentsModel(id: 2, name: "Сумма операции",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(id: 3, name: "Комиссия",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(id: 4, name: "Дата и время операции (МСК)",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(id: 5, name: "Адрес",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(id: 6, name: "Счет списания",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(id: 7, name: "Терминал",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(id: 8, name: "Мерчант",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(id: 9, name: "Код авторизации",
                          iconName: "",
                          controllerName: "",
                          description: ""),
//
//            PaymentsModel(id: 4, name: "Любимая Beeline",
////                          iconName: "bilane",
//                          avatarImageName: "bilane",
//                          controllerName: "DevelopViewController",
//                          description: "Что то"),
//
//            PaymentsModel(id: 5, name: "Обмен валют",
//                          iconName: "PaymentsIconCarancy",
//                          controllerName: "DevelopViewController",
//                          description: "Что то"),
            
        ]
    }
    
}

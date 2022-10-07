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
            
            PaymentsModel(name: "Шаблоны",
                          iconName: "star",
                          controllerName: "", type: "templates"),
        ]
    }
    
    /// Данные для заполнения экрана PaymentsController в средней секции
    class func returnTransfers() -> [PaymentsModel] {
        return [
            
            PaymentsModel(name: "По номеру телефона",
                          iconName: "PaymentsIconPhonePay",
                          controllerName: "ContactsViewController",
                          description: ""),
            PaymentsModel(name: "Между счетами",
                          iconName: "PaymentsIconMyPay",
                          controllerName: "DevelopViewController",
                          description: ""),
            
            PaymentsModel(name: "За рубеж",
                          iconName: "PaymentsIconWarldPay",
                          controllerName: "ChooseCountryTableViewController",
                          description: ""),
            
            PaymentsModel(name: "На другую карту",
                          iconName: "PaymentsIconCardPay",
                          controllerName: "DevelopViewController",
                          description: ""),
            
            PaymentsModel(name: "По реквизитaм",
                          iconName: "PaymentsIconReqPay",
                          controllerName: "TransferByRequisitesViewController",
                          description: "")
            
        ]
    }
    
    
    class func returnOpenProduct() -> [PaymentsModel] {
        return [
            PaymentsModel(name: "Карту",
                          iconName: "openCard",
                          controllerName: "https://promo.forabank.ru/?metka=leads1&affiliate_id=44935&source=leads1&transaction_id=6dae603673619b0681e492d4bd1d8f3a",
                          description: "Все включено"),
            
            PaymentsModel(name: "Вклад",
                          iconName: "openDeposit",
                          controllerName: "https://www.forabank.ru/private/deposits/",
                          description: ""),
        ]
    }
    
    /// Данные для заполнения экрана PaymentsController в нижней секции
    class func returnPay() -> [PaymentsModel] {
        return [
            PaymentsModel(name: "Оплата по QR",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "",
                          description: "QR"),
            
            PaymentsModel(name: "Мобильная связь",
                          iconName: "smartphoneblack",
                          controllerName: "MobilePayViewController",
                          description: "Что то"),
            
            PaymentsModel(name: "Услуги ЖКХ",
                          iconName: "iconLampNew",
                          controllerName: "GKHMainViewController",
                          description: "ЖКХ"),
            
            PaymentsModel(name: "Интернет, ТВ",
                          iconName: "tv",
                          controllerName: "InternetTVMainController",
                          description: "Интернет, ТВ")
            ,
            
            PaymentsModel(name: "Транспорт",
                          iconName: "carMain",
                          controllerName: "",
                          description: "Что то"),
            
            PaymentsModel(name: "Налоги и госуслуги",
                          iconName: "PaymentsIconBlazon",
                          controllerName: "",
                          description: "Что то")
        ]
    }
    
    //Для заполнения быстрых действий главный экран
    /// Данные для заполнения экрана PaymentsController в нижней секции
    class func returnFastPay() -> [PaymentsModel] {
        return [
            PaymentsModel(name: "Оплата по QR",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "QRViewController",
                          description: "QR"),
            
            PaymentsModel(name: "Перевод по номеру",
                          iconName: "smartphoneblack",
                          controllerName: "ContactsViewController",
                          description: "Что то"),
            
            PaymentsModel(name: "Шаблоны",
                          iconName: "star",
                          controllerName: "GKHMainViewController",
                          description: "ЖКХ"),
        ]
    }
    
    
    class func returnBanner() -> [PaymentsModel] {
        return [

            PaymentsModel(name: "Перевод по\nтелефону",
                          iconName: "BannerDep",
                          controllerName: "https://www.forabank.ru/private/deposits/",
                          description: "Что то"),
            PaymentsModel(name: "Перевод по\nтелефону",
                          iconName: "bannerNG",
                          controllerName: "https://www.forabank.ru/private/cards/sezonnoe-predlozhenie/",
                          description: "Что то"),
            PaymentsModel(name: "Шаблоны и\nавтоплатежи",
                          iconName: "bannerMig",
                          controllerName: "https://www.forabank.ru/landings/mig/")
        ]
    }
    class func returnCurrency() -> [PaymentsModel] {
        return [
            PaymentsModel(name: "Шаблоны и\nавтоплатежи",
                          iconName: "promoBanner2",
                          controllerName: "")
        ]
    }
    
    class func returnSectionInProducts() -> [PaymentsModel] {
        return [
            PaymentsModel(name: "Неактивированные продукты",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "https://www.forabank.ru/private/cards/",
                          description: "QR"),
            
            PaymentsModel(name: "Карты и счета",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "https://www.forabank.ru/private/cards/",
                          description: "QR"),
            
            PaymentsModel(name: "Вклады",
                          iconName: "promoBanner2",
                          controllerName: "https://www.forabank.ru/private/deposits/"),
            
            PaymentsModel(name: "Кредиты",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/credits/",
                          description: "Что то"),
            
            PaymentsModel(name: "Инвестиции",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/business/credits/investitsii/?sphrase_id=26274",
                          description: "Что то"),
            
            PaymentsModel(name: "Страховка",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: "Что то"),
            PaymentsModel(name: "Заблокированные продукты",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: "Что то")
        ]
    }
    
    class func returnsRequisits() -> [PaymentsModel] {
        return [
            PaymentsModel(name: "Получатель",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "https://www.forabank.ru/private/cards/",
                          description: ""),
            
            PaymentsModel(name: "Номер счета",
                          iconName: "promoBanner2",
                          controllerName: "https://www.forabank.ru/private/deposits/",
                          description: ""),
            
            PaymentsModel(name: "БИК",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/credits/",
                          description: ""),
            
            PaymentsModel(name: "Корреспондентский счет",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/business/credits/investitsii/?sphrase_id=26274",
                          description: ""),
            
            PaymentsModel(name: "ИНН",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(name: "КПП",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel( name: "Держатель карты",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(name: "Номер карты",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(name: "Карта действует до",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: "")
        ]
    }
    
    class func returnsDepositInfo() -> [PaymentsModel] {
        return [
            PaymentsModel(name: "Сумма первоначального размещения",
                          iconName: "PaymentsIconBarcode-scanner",
                          controllerName: "https://www.forabank.ru/private/cards/",
                          description: ""),
            
            PaymentsModel(name: "Дата открытия ",
                          iconName: "promoBanner2",
                          controllerName: "https://www.forabank.ru/private/deposits/",
                          description: ""),
            
            PaymentsModel(name: "Дата закрытия",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/credits/",
                          description: ""),
            
            PaymentsModel(name: "Срок вклада",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/business/credits/investitsii/?sphrase_id=26274",
                          description: ""),
            
            PaymentsModel(name: "Ставка по вкладу",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(name: "Дата следующего начисления процентов",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(name: "Сумма выплаченных процентов всего",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(name: "Суммы пополнений",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(name: "Суммы списаний",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: ""),
            PaymentsModel(name: "Сумма начисленных процентов на дату",
                          iconName: "PaymentsIconCarancy",
                          controllerName: "https://www.forabank.ru/private/strakhovanie/",
                          description: "")
        ]
    }
    
    class func butttonArray() -> [PaymentsModel] {
        return [
            PaymentsModel(name: "+ Шаблон",
                          iconName: "star24size",
                          controllerName: "https://www.forabank.ru/private/cards/",
                          description: "QR"),
            
            PaymentsModel(name: "Документ",
                          iconName: "doc",
                          controllerName: "https://www.forabank.ru/private/deposits/",
                          description: "Что то"),
            
            PaymentsModel(name: "Детали",
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
            
            PaymentsModel(name: "Название",
                          iconName: "",
                          controllerName: ""),
            
            PaymentsModel(name: "Сумма операции",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(name: "Комиссия",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(name: "Дата и время операции (МСК)",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(name: "Адрес",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(name: "Счет списания",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(name: "Терминал",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(name: "Мерчант",
                          iconName: "",
                          controllerName: "",
                          description: ""),
            PaymentsModel(name: "Код авторизации",
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
    
//    class func returnOperationDetails() -> OperationDetailDatum {
//        OperationDetailDatum(
//            payeeFullName: "Алексей Андреевич К.",
//            payeeFirstName: "Алексей",
//            payeeMiddleName: "Андреевич",
//            payeeSurName: "Косарев",
//            payeePhone: "+79279890100",
//            payeeCardNumber: nil,
//            payeeAmount: 100,
//            amount: 100,
//            claimID: "085b2c5e-8415-452c-9fe0-dacb423203b8",
//            transferDate:  "24.12.2021",
//            responseDate: "24.12.2021",
//            currencyAmount: "RUB",
//            payerFee: nil,
//            fullAmount: nil,
//            payerAccountNumber: "Савушкин Дмитрий Александрович",
//            payerCurrency: "RUB",
//            payerCardNumber: "**** **** **50 2631",
//            payeeBankName: "internal",
//            payerFullName: nil,
//            payerDocument: "24.12.2021 20:33:58",
//            requestDate: "RUB",
//            payerAmount: 100.00,
//            paymentOperationDetailID: 7827,
//            printFormType: nil,
//            dateForDetail:  "24 декабря 2021, 20:33",
//            memberID: "24.12.2021 20:33:34",
//            transferEnum: nil,
//            transferReference: "INTERNAL",
//            account: nil,
//            payeeAccountNumber: nil,
//            countryName: nil,
//            payeeBankBIC: nil,
//            payeeINN: nil,
//            payeeKPP: nil,
//            provider: nil,
//            period: nil,
//            transferNumber: nil,
//            accountTitle: "Номер телефона",
//            isTrafficPoliceService: false,
//            paymentTemplateId: nil,
//            payeeAccountId: nil,
//            payeeCardId: nil,
//            payeeCurrency: "USD"
//
//        )
//    }
}


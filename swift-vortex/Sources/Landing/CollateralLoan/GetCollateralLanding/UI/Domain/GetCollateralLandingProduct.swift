//
//  GetCollateralLandingProduct.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import Foundation
import DropDownTextListComponent

public struct GetCollateralLandingProduct: Equatable {
    
    public let theme: Theme
    public let name: String
    public let marketing: Marketing
    public let conditions: [Condition]
    public let calc: Calc
    public let faq: [Faq]
    public let documents: [Document]
    public let consents: [Consent]
    public let cities: [String]
    public let icons: Icons
    
    public init(
        theme: Theme,
        name: String,
        marketing: Marketing,
        conditions: [Condition],
        calc: Calc,
        faq: [Faq],
        documents: [Document],
        consents: [Consent],
        cities: [String],
        icons: Icons
    ) {
        self.theme = theme
        self.name = name
        self.marketing = marketing
        self.conditions = conditions
        self.calc = calc
        self.faq = faq
        self.documents = documents
        self.consents = consents
        self.cities = cities
        self.icons = icons
    }
    
    public enum Theme: String {
        
        case gray
        case white
        case unknown
    }
    
    public struct Marketing: Equatable {
        
        public let labelTag: String
        public let image: String
        public let params: [String]
        
        public init(
            labelTag: String,
            image: String,
            params: [String]
        ) {
            self.labelTag = labelTag
            self.image = image
            self.params = params
        }
    }
    
    public struct Condition: Equatable {
        
        public let icon: String
        public let title: String
        public let subTitle: String
        
        public init(icon: String, title: String, subTitle: String) {
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
        }
    }
    
    public struct Calc: Equatable {
        
        public let amount: Amount
        public let collaterals: [Collateral]
        public let rates: [Rate]
        
        public init(amount: Amount, collaterals: [Collateral], rates: [Rate]) {
            self.amount = amount
            self.collaterals = collaterals
            self.rates = rates
        }
        
        public struct Amount: Equatable {
            
            public let minIntValue: UInt
            public let maxIntValue: UInt
            public let maxStringValue: String
            
            public init(
                minIntValue: UInt,
                maxIntValue: UInt,
                maxStringValue: String
            ) {
                self.minIntValue = minIntValue
                self.maxIntValue = maxIntValue
                self.maxStringValue = maxStringValue
            }
        }
        
        public struct Collateral: Equatable {
            
            public let icon: String
            public let name: String
            public let type: String
            
            public init(icon: String, name: String, type: String) {
                
                self.icon = icon
                self.name = name
                self.type = type
            }
        }
        
        public struct Rate: Equatable {
            
            public let rateBase: Double
            public let ratePayrollClient: Double
            public let termMonth: UInt
            public let termStringValue: String
            
            public init(
                rateBase: Double,
                ratePayrollClient: Double,
                termMonth: UInt,
                termStringValue: String
            ) {
                self.rateBase = rateBase
                self.ratePayrollClient = ratePayrollClient
                self.termMonth = termMonth
                self.termStringValue = termStringValue
            }
        }
    }
    
    public struct Faq: Equatable {
        
        public let question: String
        public let answer: String
        
        public init(question: String, answer: String) {
            
            self.question = question
            self.answer = answer
        }
    }
    
    public struct Document: Equatable, Identifiable {
        
        public var id = UUID()
        public let title: String
        public let icon: String?
        public let link: String
        
        public init(title: String, icon: String?, link: String) {
            
            self.title = title
            self.icon = icon
            self.link = link
        }
    }
    
    public struct Consent: Equatable {
        
        public let name: String
        public let link: String
        
        public init(name: String, link: String) {
            
            self.name = name
            self.link = link
        }
    }
    
    public struct Icons: Equatable {
        
        public let productName: String
        public let amount: String
        public let term: String
        public let rate: String
        public let city: String
        
        public init(
            productName: String,
            amount: String,
            term: String,
            rate: String,
            city: String
        ) {
            self.productName = productName
            self.amount = amount
            self.term = term
            self.rate = rate
            self.city = city
        }
    }
}

extension GetCollateralLandingProduct {
    
    public var getCollateralLandingTheme: GetCollateralLandingTheme {

        switch self.theme {

        case .white:
            return .white
        case .gray:
            return .gray
        default:
            return .white
        }
    }
}

extension GetCollateralLandingProduct.Faq: Hashable {}

extension GetCollateralLandingProduct {
    
    var dropDownTextList: DropDownTextList {
        
        .init(
            title: "Часто задаваемые вопросы",
            items: faq.map { .init(title: $0.question, subTitle: $0.answer) }
        )
    }
}

extension GetCollateralLandingProduct.Calc.Rate {
    
    var bottomSheetItem: GetCollateralLandingDomain.State.BottomSheet.Item {
        
        .init(
            id: UUID().uuidString,
            termMonth: termMonth,
            icon: nil,
            title: termStringValue
        )
    }
}

extension GetCollateralLandingProduct.Calc.Collateral {
    
    var bottomSheetItem: GetCollateralLandingDomain.State.BottomSheet.Item {
        
        .init(
            id: type,
            termMonth: nil,
            icon: icon,
            title: name
        )
    }
}

// For preview only
extension GetCollateralLandingProduct {
    
    static let carStub = Self(
        theme: .unknown,
        name: "Кредит под залог транспорта",
        marketing: .init(
            labelTag: "до 15 млн. ₽",
            image: "dict/getProductCatalogImage?image=/products/landing-image/collateral-loan/product_car_collateral_loan_750×1408.png",
            params: [
                "Ставка - от 17,5%",
                "до 15 млн. ₽",
                "Срок -  До 84 мес."
            ]
        ),
        conditions: [
            .init(
                icon: "b6fa019f307d6a72951ab7268708aa15",
                title: "Срок рассмотрения заявки",
                subTitle: "До 3 рабочих дней со дня предоставления полного пакета документов"
            ),
            .init(
                icon: "b6fa019f307d6a72951ab7268708aa15",
                title: "Досрочное погашение кредита",
                subTitle: "Без ограничений"
            ),
            .init(
                icon: "b6fa019f307d6a72951ab7268708aa15",
                title: "Комиссии за выдачу",
                subTitle: "Отсутствует"
            )
        ],
        calc: .init(
            amount: .init(
                minIntValue: 750000,
                maxIntValue: 15000000,
                maxStringValue: "До 15 млн. ₽"
            ),
            collaterals: [
                .init(
                    icon: "0e74ec16a34028c0b963b8ddfa934240",
                    name: "Автомобиль",
                    type: "CAR"
                ),
                .init(
                    icon: "b3c9b796fd04cdb8909675b2b6ebca65",
                    name: "Иное движимое имущество",
                    type: "OTHER_MOVABLE_PROPERTY"
                ),
            ],
            rates: [
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 6,
                    termStringValue: "6 месяцев"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 9,
                    termStringValue: "9 месяцев"
                ),
                .init(
                    rateBase: 19.5,
                    ratePayrollClient: 18.5,
                    termMonth: 12,
                    termStringValue: "1 год"
                ),
                .init(
                    rateBase: 19.5,
                    ratePayrollClient: 18.5,
                    termMonth: 24,
                    termStringValue: "2 года"
                ),
                .init(
                    rateBase: 19.5,
                    ratePayrollClient: 18.5,
                    termMonth: 36,
                    termStringValue: "3 года"
                ),
                .init(
                    rateBase: 19.5,
                    ratePayrollClient: 18.5,
                    termMonth: 48,
                    termStringValue: "4 года"
                ),
                .init(
                    rateBase: 19.5,
                    ratePayrollClient: 18.5,
                    termMonth: 60,
                    termStringValue: "5 лет"
                ),
                .init(
                    rateBase: 19.5,
                    ratePayrollClient: 18.5,
                    termMonth: 72,
                    termStringValue: "6 лет"
                ),
                .init(
                    rateBase: 19.5,
                    ratePayrollClient: 18.5,
                    termMonth: 84,
                    termStringValue: "7 лет"
                ),
            ]
        ),
        faq: [
            .init(
                question: "какой кредит выгоднее оформить залоговый или взять несколько потребительских кредитов без обязательного подтверждения целевого использования и оформления залога?",
                answer: "при наличии, имущества которое можно передать в залог банку конечно выгоднее оформить залоговый кредит по таким кредитам процентная ставка будет значительно меньше, а срок и сумма кредита всегда больше чем у без залогового потребительского кредита."
            ),
            .init(
                question: "Какое имущество я могу передать в залог банку по кредиту?",
                answer: "В залог может быть передано любое движимое или недвижимое имущество, а также ценные бумаги, или права требования, передаваемом в залог имуществе не должно быть обременено правами третьих лиц."
            ),
            .init(
                question: "Как можно увеличить сумму кредита?",
                answer: "Если вашего дохода недостаточно, то вы можете привлечь созаемщика с доходом, созаемщиком может являться любое физическое лицо."
            ),
            .init(
                question: "На какие цели может быть взят кредит?",
                answer: "Кредит может быть предоставлен на любые потребительские цели, не связанные с ведением предпринимательской деятельности, такие как: приобретение в собственность недвижимости или транспортного средства, ремонт или строительство недвижимости, погашение обязательств по иным потребительским кредитам и иные потребительские цели, но целевое использование кредита обязательно должно быть подтверждено в течении 90 дней с даты выдачи кредита, способ подтверждения зависит от цели использования средств например можно предоставить платежные документы и договора приобретения/подряда/оказания услуг, а при приобретении недвижимости дополнительно информацию из ЕГРН о зарегистрированном праве собственности."
            ),
            .init(
                question: "необходимо ли оформлять страховку при получении кредита и зависит ли процентная ставка по кредиту от страховки?",
                answer: "Нужно страховать только риск утраты и повреждения недвижимого имущества при его залоге, такие риски как утрата права собственности или страхование жизни и здоровья страховать не требуется, при их отсутствии процентная ставка не увеличивается. "
            ),
            .init(
                question: "Нужно ли проводить платную независимую оценку закладываемого имущества?",
                answer: "Банк сам оценит стоимость предложенного залога, оценка производится для вас бесплатно."
            ),
            .init(
                question: "Каким образом может быть подтвержден доход для расчета доступной суммы кредита?",
                answer: "Если вы получаете заработную плату на карту нашего банка, то вам не потребуется дополнительно подтверждать размер дохода, в ином случае доход можно подтвердить, предоставив извещение о состоянии лицевого счета СФР выгрузив его в личном кабинете на портале Госуслуг или предоставив справку о доходах полученную у работодателя, возможны иные варианты подтверждения дохода."
            )
        ],
        documents: [
            .init(
                title: "Общие условия потребительского кредита «Инновации-Залоговый",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/d67/9rzpifz1bge1i4o19lkemdhipa9qe5ka/Obshchie-usloviya-Potrebitelskogo-kredita-Vortex_Zalogovyi_.docx"
            ),
            .init(
                title: "Заявление-анкета на получение потребительского кредита",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/6d6/s12sqm6nam4snqcv3kzol9n4lesnxn7e/Zayavlenie_Anketa.doc"
            ),
            .init(
                title: "Требования к заемщику",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/2a0/j6146tbcv7pl537r3q0mpak5nlqkbq1w/Trebovaniya-k-Zaemshchiku-po-programme-Potrebitelskogo-kreditovaniya-Vortex_Zalogovyi_.doc"
            ),
            .init(
                title: "Необходимые документы для оформления потребительского кредита",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/851/b037f9qkn44k4xpirgywro47xz1cq09i/Neobkhodimyi_-dokumenty-dlya-oformleniya-Potrebitelskogo-kredita-Vortex_Zalogovyi_.docx"
            ),
            .init(
                title: "Список документов по залогу (недвижимость)",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/ac9/b20ixpqsk2bj5i9yobnobvagb06g33lj/Spisok-dokumentov-po-zalogu-_nedvizhimost_-Vortex_Zalogovyi_.docx"
            ),
            .init(
                title: "Условия договора потребительского кредита",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/e45/fq1nlaqlozhvjoo12qp4orcjrhsippea/OBSHCHIE-USLOVIYA-POTREBITELSKOGO-KREDITOVANIYA.pdf"
            )
        ],
        consents: [
            .init(
                name: "Согласие 1",
                link: "https://www.vortex.ru/"
            ),
            .init(
                name: "Согласие 2",
                link: "https://www.vortex.ru/"
            )
        ],
        cities: [
            "Москва",
            "п.Коммунарка",
            "Реутов",
            "Орехово-Зуево",
            "Апрелевка",
            "Наро-Фоминск",
            "Подольск",
            "Балашиха",
            "Люберцы",
            "Одинцово",
            "Химки",
            "Мытищи",
            "Красногорск",
            "Серпухов",
            "Домодедово",
            "п.Случайный",
            "Калуга",
            "Обнинск",
            "п.Воротынск",
            "Малоярославец",
            "Балабаново",
            "Тула",
            "Коломна",
            "Ярославль",
            "Рыбинск",
            "Иваново",
            "Пермь",
            "Саранск",
            "Нижний Новгород",
            "Ростов-на-Дону",
            "Сочи",
            "Краснодар",
            "Армавир",
            "Тамбов",
            "Санкт-Петербург",
            "Ставрополь",
            "Тверь",
            "Липецк"
        ],
        icons: .init(
            productName: "f27bc04694e1d26d6df6d62fd3a24d9c",
            amount: "a338034a5b4b773761846780a9b1f473",
            term: "8fcaf5ddfa899578c13f45f63f662cdd",
            rate: "38ef9ce16cb49821559cdbee4109bc82",
            city: "bc750d97c57bb11a1b82a175d9d13460"
        )
    )
}

extension GetCollateralLandingProduct {
    
    static let realEstateStub = Self(
        theme: .unknown,
        name: "Кредит под залог недвижимости",
        marketing: .init(
            labelTag: "до 15 млн. ₽",
            image: "dict/getProductCatalogImage?image=/products/landing-image/collateral-loan/product_real_estate_collateral_loan_750×1406.png",
            params: [
                "Ставка - от 17,5%",
                "до 15 млн. ₽",
                "Срок -  До 84 мес."
            ]
        ),
        conditions: [
            .init(
                icon: "b6fa019f307d6a72951ab7268708aa15",
                title: "Срок рассмотрения заявки",
                subTitle: "До 3 рабочих дней со дня предоставления полного пакета документов"
            ),
            .init(
                icon: "b6fa019f307d6a72951ab7268708aa15",
                title: "Досрочное погашение кредита",
                subTitle: "Без ограничений"
            ),
            .init(
                icon: "b6fa019f307d6a72951ab7268708aa15",
                title: "Комиссии за выдачу",
                subTitle: "Отсутствует"
            )
        ],
        calc: .init(
            amount: .init(
                minIntValue: 750000,
                maxIntValue: 15000000,
                maxStringValue: "До 15 млн. ₽"
            ),
            collaterals: [
                .init(
                    icon: "864514356fd3192601f1e82feb04f123",
                    name: "Квартира",
                    type: "APARTMENT"
                ),
                .init(
                    icon: "2140c05c3aca8c0edde293b8690941cb",
                    name: "Дом",
                    type: "HOUSE"
                ),
                .init(
                    icon: "317cbd287d3c4b2b9ece88e2ee9a2d88",
                    name: "Земельный участок",
                    type: "LAND_PLOT"
                ),
                .init(
                    icon: "2937d7cb96164a2aced989848684ca78",
                    name: "Коммерческая недвижимость",
                    type: "COMMERCIAL_PROPERTY"
                ),
            ],
            rates: [
                .init(
                    rateBase: 17.5,
                    ratePayrollClient: 16.5,
                    termMonth: 6,
                    termStringValue: "6 месяцев"
                ),
                .init(
                    rateBase: 17.5,
                    ratePayrollClient: 16.5,
                    termMonth: 9,
                    termStringValue: "9 месяцев"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 12,
                    termStringValue: "1 год"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 24,
                    termStringValue: "2 года"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 36,
                    termStringValue: "3 года"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 48,
                    termStringValue: "4 года"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 60,
                    termStringValue: "5 лет"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 72,
                    termStringValue: "6 лет"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 84,
                    termStringValue: "7 лет"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 96,
                    termStringValue: "8 лет"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 108,
                    termStringValue: "9 лет"
                ),
                .init(
                    rateBase: 18.5,
                    ratePayrollClient: 17.5,
                    termMonth: 120,
                    termStringValue: "10 лет"
                ),
            ]
        ),
        faq: [
            .init(
                question: "какой кредит выгоднее оформить залоговый или взять несколько потребительских кредитов без обязательного подтверждения целевого использования и оформления залога?",
                answer: "при наличии, имущества которое можно передать в залог банку конечно выгоднее оформить залоговый кредит по таким кредитам процентная ставка будет значительно меньше, а срок и сумма кредита всегда больше чем у без залогового потребительского кредита."
            ),
            .init(
                question: "Какое имущество я могу передать в залог банку по кредиту?",
                answer: "В залог может быть передано любое движимое или недвижимое имущество, а также ценные бумаги, или права требования, передаваемом в залог имуществе не должно быть обременено правами третьих лиц."
            ),
            .init(
                question: "Как можно увеличить сумму кредита?",
                answer: "Если вашего дохода недостаточно, то вы можете привлечь созаемщика с доходом, созаемщиком может являться любое физическое лицо."
            ),
            .init(
                question: "На какие цели может быть взят кредит?",
                answer: "Кредит может быть предоставлен на любые потребительские цели, не связанные с ведением предпринимательской деятельности, такие как: приобретение в собственность недвижимости или транспортного средства, ремонт или строительство недвижимости, погашение обязательств по иным потребительским кредитам и иные потребительские цели, но целевое использование кредита обязательно должно быть подтверждено в течении 90 дней с даты выдачи кредита, способ подтверждения зависит от цели использования средств например можно предоставить платежные документы и договора приобретения/подряда/оказания услуг, а при приобретении недвижимости дополнительно информацию из ЕГРН о зарегистрированном праве собственности."
            ),
            .init(
                question: "необходимо ли оформлять страховку при получении кредита и зависит ли процентная ставка по кредиту от страховки?",
                answer: "Нужно страховать только риск утраты и повреждения недвижимого имущества при его залоге, такие риски как утрата права собственности или страхование жизни и здоровья страховать не требуется, при их отсутствии процентная ставка не увеличивается. "
            ),
            .init(
                question: "Нужно ли проводить платную независимую оценку закладываемого имущества?",
                answer: "Банк сам оценит стоимость предложенного залога, оценка производится для вас бесплатно."
            ),
            .init(
                question: "Каким образом может быть подтвержден доход для расчета доступной суммы кредита?",
                answer: "Если вы получаете заработную плату на карту нашего банка, то вам не потребуется дополнительно подтверждать размер дохода, в ином случае доход можно подтвердить, предоставив извещение о состоянии лицевого счета СФР выгрузив его в личном кабинете на портале Госуслуг или предоставив справку о доходах полученную у работодателя, возможны иные варианты подтверждения дохода."
            )
        ],
        documents: [
            .init(
                title: "Общие условия потребительского кредита «Инновации-Залоговый",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/d67/9rzpifz1bge1i4o19lkemdhipa9qe5ka/Obshchie-usloviya-Potrebitelskogo-kredita-Vortex_Zalogovyi_.docx"
            ),
            .init(
                title: "Заявление-анкета на получение потребительского кредита",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/6d6/s12sqm6nam4snqcv3kzol9n4lesnxn7e/Zayavlenie_Anketa.doc"
            ),
            .init(
                title: "Требования к заемщику",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/2a0/j6146tbcv7pl537r3q0mpak5nlqkbq1w/Trebovaniya-k-Zaemshchiku-po-programme-Potrebitelskogo-kreditovaniya-Vortex_Zalogovyi_.doc"
            ),
            .init(
                title: "Необходимые документы для оформления потребительского кредита",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/851/b037f9qkn44k4xpirgywro47xz1cq09i/Neobkhodimyi_-dokumenty-dlya-oformleniya-Potrebitelskogo-kredita-Vortex_Zalogovyi_.docx"
            ),
            .init(
                title: "Список документов по залогу (недвижимость)",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/ac9/b20ixpqsk2bj5i9yobnobvagb06g33lj/Spisok-dokumentov-po-zalogu-_nedvizhimost_-Vortex_Zalogovyi_.docx"
            ),
            .init(
                title: "Условия договора потребительского кредита",
                icon: "4c6e32a2f66f18484394c3520e9e2c25",
                link: "https://www.vortex.ru/upload/iblock/e45/fq1nlaqlozhvjoo12qp4orcjrhsippea/OBSHCHIE-USLOVIYA-POTREBITELSKOGO-KREDITOVANIYA.pdf"
            )
        ],
        consents: [
            .init(
                name: "Согласие 1",
                link: "https://www.vortex.ru/"
            ),
            .init(
                name: "Согласие 2",
                link: "https://www.vortex.ru/"
            )
        ],
        cities: [
            "Москва",
            "п.Коммунарка",
            "Реутов",
            "Орехово-Зуево",
            "Апрелевка",
            "Наро-Фоминск",
            "Подольск",
            "Балашиха",
            "Люберцы",
            "Одинцово",
            "Химки",
            "Мытищи",
            "Красногорск",
            "Серпухов",
            "Домодедово",
            "п.Случайный",
            "Калуга",
            "Обнинск",
            "п.Воротынск",
            "Малоярославец",
            "Балабаново",
            "Тула",
            "Коломна",
            "Ярославль",
            "Рыбинск",
            "Иваново",
            "Пермь",
            "Саранск",
            "Нижний Новгород",
            "Ростов-на-Дону",
            "Сочи",
            "Краснодар",
            "Армавир",
            "Тамбов",
            "Санкт-Петербург",
            "Ставрополь",
            "Тверь",
            "Липецк"
        ],
        icons: .init(
            productName: "96570b79cff91f563eef53347db9e398",
            amount: "a338034a5b4b773761846780a9b1f473",
            term: "8fcaf5ddfa899578c13f45f63f662cdd",
            rate: "38ef9ce16cb49821559cdbee4109bc82",
            city: "bc750d97c57bb11a1b82a175d9d13460"
        )
    )
}

extension GetCollateralLandingProduct {
    
    public static let empty = Self(
        theme: .unknown,
        name: "",
        marketing: .empty,
        conditions: [],
        calc: .empty,
        faq: [],
        documents: [],
        consents: [],
        cities: [],
        icons: .empty
    )
}

extension GetCollateralLandingProduct.Marketing {
    
    static let empty = Self(
        labelTag: "",
        image: "",
        params: []
    )
}

extension GetCollateralLandingProduct.Calc {
    
    static let empty = Self(
        amount: .empty,
        collaterals: [],
        rates: []
    )
}

extension GetCollateralLandingProduct.Calc.Amount {
    
    static let empty = Self(
        minIntValue: 0,
        maxIntValue: 0,
        maxStringValue: ""
    )
}

extension GetCollateralLandingProduct.Icons {
    
    static let empty = Self(
        productName: "",
        amount: "",
        term: "",
        rate: "",
        city: ""
    )
}

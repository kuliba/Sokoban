//
//  CollateralLoanLandingGetCollateralLandingView.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

import SwiftUI

struct CollateralLoanLandingGetCollateralLandingView: View {
    
    private let content: Content
    private let factory: Factory
    
    init(
        content: Content,
        factory: Factory
    ) {
        self.content = content
        self.factory = factory
    }
    
    var body: some View {
        
        factory.makeView(content.data.product)
    }
}

extension CollateralLoanLandingGetCollateralLandingView {
    
    typealias Content = CollateralLoanLandingGetCollateralLandingContent
    typealias Factory = CollateralLoanLandingGetCollateralLandingViewFactory
}

extension GetCollateralLandingData {
    
    static let cardStub = Self(
        product: .init(
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
                collateral: [
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
                ],
                frequentlyAskedQuestions: [
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
                        title: "Общие условия потребительского кредита «Фора-Залоговый",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/d67/9rzpifz1bge1i4o19lkemdhipa9qe5ka/Obshchie-usloviya-Potrebitelskogo-kredita-Fora_Zalogovyi_.docx"
                    ),
                    .init(
                        title: "Заявление-анкета на получение потребительского кредита",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/6d6/s12sqm6nam4snqcv3kzol9n4lesnxn7e/Zayavlenie_Anketa.doc"
                    ),
                    .init(
                        title: "Требования к заемщику",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/2a0/j6146tbcv7pl537r3q0mpak5nlqkbq1w/Trebovaniya-k-Zaemshchiku-po-programme-Potrebitelskogo-kreditovaniya-Fora_Zalogovyi_.doc"
                    ),
                    .init(
                        title: "Необходимые документы для оформления потребительского кредита",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/851/b037f9qkn44k4xpirgywro47xz1cq09i/Neobkhodimyi_-dokumenty-dlya-oformleniya-Potrebitelskogo-kredita-Fora_Zalogovyi_.docx"
                    ),
                    .init(
                        title: "Список документов по залогу (недвижимость)",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/ac9/b20ixpqsk2bj5i9yobnobvagb06g33lj/Spisok-dokumentov-po-zalogu-_nedvizhimost_-Fora_Zalogovyi_.docx"
                    ),
                    .init(
                        title: "Условия договора потребительского кредита",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/e45/fq1nlaqlozhvjoo12qp4orcjrhsippea/OBSHCHIE-USLOVIYA-POTREBITELSKOGO-KREDITOVANIYA.pdf"
                    )
                ],
                consents: [
                    .init(
                        name: "Согласие 1",
                        link: "https://www.forabank.ru/"
                    ),
                    .init(
                        name: "Согласие 2",
                        link: "https://www.forabank.ru/"
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
        )
    )
}

extension GetCollateralLandingData {
    
    static let realEstateStub = Self(
        product: .init(
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
                collateral: [
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
                ],
                frequentlyAskedQuestions: [
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
                        title: "Общие условия потребительского кредита «Фора-Залоговый",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/d67/9rzpifz1bge1i4o19lkemdhipa9qe5ka/Obshchie-usloviya-Potrebitelskogo-kredita-Fora_Zalogovyi_.docx"
                    ),
                    .init(
                        title: "Заявление-анкета на получение потребительского кредита",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/6d6/s12sqm6nam4snqcv3kzol9n4lesnxn7e/Zayavlenie_Anketa.doc"
                    ),
                    .init(
                        title: "Требования к заемщику",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/2a0/j6146tbcv7pl537r3q0mpak5nlqkbq1w/Trebovaniya-k-Zaemshchiku-po-programme-Potrebitelskogo-kreditovaniya-Fora_Zalogovyi_.doc"
                    ),
                    .init(
                        title: "Необходимые документы для оформления потребительского кредита",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/851/b037f9qkn44k4xpirgywro47xz1cq09i/Neobkhodimyi_-dokumenty-dlya-oformleniya-Potrebitelskogo-kredita-Fora_Zalogovyi_.docx"
                    ),
                    .init(
                        title: "Список документов по залогу (недвижимость)",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/ac9/b20ixpqsk2bj5i9yobnobvagb06g33lj/Spisok-dokumentov-po-zalogu-_nedvizhimost_-Fora_Zalogovyi_.docx"
                    ),
                    .init(
                        title: "Условия договора потребительского кредита",
                        icon: "4c6e32a2f66f18484394c3520e9e2c25",
                        link: "https://www.forabank.ru/upload/iblock/e45/fq1nlaqlozhvjoo12qp4orcjrhsippea/OBSHCHIE-USLOVIYA-POTREBITELSKOGO-KREDITOVANIYA.pdf"
                    )
                ],
                consents: [
                    .init(
                        name: "Согласие 1",
                        link: "https://www.forabank.ru/"
                    ),
                    .init(
                        name: "Согласие 2",
                        link: "https://www.forabank.ru/"
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
        )
    )
}

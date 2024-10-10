//
//  CollateralLoanLandingShowCaseModel+Mock.swift
//  swift-forabank
//
//  Created by Valentin Ozerov on 08.10.2024.
//

import RemoteServices

@testable import CollateralLoanLanding

extension ResponseMapper.CollateralLoanLandingShowCaseModel {
    
    static let stub = Self(
        serial: "serial",
        products: [.stub]
    )
    
    static let empty = Self(
        serial: "serial",
        products: []
    )
}

extension ResponseMapper.CollateralLoanLandingShowCaseModel.Product {

    static let stub = Self(
        theme: .gray,
        name: "name",
        terms: "terms",
        landingId: "landingId",
        image: "image",
        keyMarketingParams: .stub,
        features: .stub
    )
}

extension ResponseMapper.CollateralLoanLandingShowCaseModel.Product.KeyMarketingParams {

    static let stub = Self(
        rate: "rate",
        amount: "amount",
        term: "term"
    )
}

extension ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Features {
    
    static let stub = Self(
        header: "header",
        list: [.stub]
    )
}

extension ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Features.List {

    static let stub = Self(
        bullet: true,
        text: "text"
    )
}

extension ResponseMapper.CollateralLoanLandingShowCaseModel {
    
    static let validStub = Self(
        serial: "d0f7b46028dc52536477c4639198658a",
        products: [
            .init(
                theme: .gray,
                name: "Кредит под залог транспорта",
                terms: "https://www.forabank.ru/",
                landingId: "COLLATERAL_LOAN_CALC_CAR",
                image: "dict/getProductCatalogImage?image=/products/landing-image/collateral-loan/list_car_collateral_loan.png",
                keyMarketingParams: .init(
                    rate: "от 17,5%",
                    amount: "до 15 млн ₽",
                    term: "До 84 месяцев"
                ),
                features: .init(
                    header: nil,
                    list: [
                        .init(
                            bullet: true,
                            text: "0 ₽. Условия обслуживания"
                        ),
                        .init(
                            bullet: false,
                            text: "Кешбэк до 10 000 ₽ в месяц"
                        ),
                        .init(
                            bullet: true,
                            text: "5% выгода при покупке топлива"
                        )
                    ]
                )
            ),
            .init(
                theme: .white,
                name: "Кредит под залог недвижимости",
                terms: "https://www.forabank.ru/",
                landingId: "COLLATERAL_LOAN_CALC_REAL_ESTATE",
                image: "dict/getProductCatalogImage?image=/products/landing-image/collateral-loan/list_real_estate_collateral_loan.png",
                keyMarketingParams: .init(
                    rate: "от 16,5 %",
                    amount: "до 15 млн. ₽",
                    term: "до 10 лет"
                ),
                features: .init(
                    header: "Под залог:",
                    list: [
                        .init(
                            bullet: false,
                            text: "Квартиры"
                        ),
                        .init(
                            bullet: false,
                            text: "Жилого дома с земельным участком"
                        ),
                        .init(
                            bullet: true,
                            text: "Нежилого или складского помещения"
                        )
                    ]
                )
            )
        ]
    )
}

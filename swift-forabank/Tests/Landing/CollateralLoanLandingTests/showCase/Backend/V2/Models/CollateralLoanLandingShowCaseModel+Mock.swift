//
//  CollateralLoanLandingShowCaseModel+Mock.swift
//  swift-forabank
//
//  Created by Valentin Ozerov on 08.10.2024.
//

import RemoteServices

@testable import CollateralLoanLanding

extension ResponseMapper.CollateralLoanLandingShowCaseModel {
    static let mock = Self(
        serial: "serial",
        id: "id",
        products: [.mock]
    )
    
    static let empty = Self(
        serial: nil,
        id: "id",
        products: []
    )
}

extension ResponseMapper.CollateralLoanLandingShowCaseModel.Product {
    static let mock = Self(
        theme: .gray,
        name: "name",
        terms: "terms",
        landingId: "landingId",
        keyMarketingParams: .mock,
        features: .mock
    )
}

extension ResponseMapper.CollateralLoanLandingShowCaseModel.Product.KeyMarketingParams {
    static let mock = Self(
        rate: "rate",
        amount: "amount",
        term: "term"
    )
}

extension ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Features {
    static let mock = Self(
        header: "header",
        image: "image",
        lists: [.mock]
    )
}

extension ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Features.List {
    static let mock = Self(
        bullet: "bullet",
        text: "text"
    )
}

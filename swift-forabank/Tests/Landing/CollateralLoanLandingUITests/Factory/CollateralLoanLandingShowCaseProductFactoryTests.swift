//
//  CollateralLoanLandingShowCaseProductFactoryTests.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import XCTest

@testable import CollateralLoanLandingUI

final class CollateralLoanLandingShowCaseProductFactoryTests: XCTestCase {

    func test_makeBulletsView() {

        // Arrange
        let sut = makeSUT()
        
        // Act
        let result = sut.makeBulletsView(with: .stub2)
        
        // Assert
        XCTAssertEqual(result?.header, "Под залог:")
    }
    
    func test_makeTermsView() {

        // Arrange
        let sut = makeSUT()

        // Act
        let result = sut.makeTermsView(with: .stub2)

        // Assert
        XCTAssertEqual(result?.params.amount, "До 15 млн. ₽")
    }

    func test_makeFooterView() {

        // Arrange
        let sut = makeSUT()

        // Act
        let result = sut.makeFooterView(with: .stub2)

        // Assert
        XCTAssertEqual(result.theme.foregroundColor, .primary)
    }

    func test_makeHeaderView() {

        // Arrange
        let sut = makeSUT()

        // Act
        let result = sut.makeHeaderView(with: .stub2)

        // Assert
        XCTAssertEqual(result?.title, "Кредит под залог недвижимости")
    }

    func test_makeImageView() {

        // Arrange
        let sut = makeSUT()
        
        // Act
        let result = sut.makeImageView(with: .stub2)

        // Assert
        XCTAssertEqual(result?.url, "dict/getProductCatalogImage?image=/products/landing-image/collateral-loan/list_real_estate_collateral_loan.png")
    }

    func test_makeView() {

        // Arrange
        let sut = makeSUT()

        // Act
        let result = sut.makeView(with: .stub2)

        // Assert
        XCTAssertNotNil(result.headerView)
        XCTAssertNotNil(result.termsView)
        XCTAssertNotNil(result.bulletsView)
        XCTAssertNotNil(result.imageView)
        XCTAssertNotNil(result.footerView)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        storeURL: URL? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> CollateralLoanLandingShowCaseProductFactory {
        .init(config: .base)
    }
}

fileprivate extension CollateralLoanLandingShowCaseUIModel {

    static let stub = Self(
        products: [.stub1, .stub2]
    )
}

fileprivate extension CollateralLoanLandingShowCaseUIModel.Product {
    
    static let stub1 = Self(
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
                .init(bullet: true, text: "0 ₽. Условия обслуживания"),
                .init(bullet: false, text: "Кешбэк до 10 000 ₽ в месяц"),
                .init(bullet: true, text: "5% выгода при покупке топлива")
            ]
        )
    )
    
    static let stub2 = Self(
        theme: .white,
        name: "Кредит под залог недвижимости",
        terms: "https://www.forabank.ru/",
        landingId: "COLLATERAL_LOAN_CALC_REAL_ESTATE",
        image: "dict/getProductCatalogImage?image=/products/landing-image/collateral-loan/list_real_estate_collateral_loan.png",
        keyMarketingParams: .init(
            rate: "от 16,5 %",
            amount: "До 15 млн. ₽",
            term: "до 10 лет"
        ),
        features: .init(
            header: "Под залог:",
            list: [
                .init(bullet: false, text: "Квартиры"),
                .init(bullet: false, text: "Жилого дома с земельным участком"),
                .init(bullet: true, text: "Нежилого или складского помещения")
            ]
        )
    )
}

//
//  CollateralLoanLandingShowCaseProductFactoryTests.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

import XCTest
import SwiftUI

@testable import CollateralLoanLandingUI

final class CollateralLoanLandingShowCaseProductFactoryTests<ContentView, SpinnerView>: XCTestCase
where ContentView: View,
      SpinnerView: View
{

    func test_makeBulletsForProductView() {

        let sut = makeSUT()
        let result = sut.makeBulletsView(with: .stub2)
        XCTAssertNoDiff(result.header, Product.stub2.features.header)
    }
    
    func test_makeTermsForProductView() {

        let sut = makeSUT()
        let result = sut.makeTermsView(with: .stub2)
        XCTAssertNoDiff(result.params.amount, Product.stub2.terms)
    }

    func test_makeFooterForProductView() {

        let sut = makeSUT()
        let result = sut.makeFooterView(with: .stub2)
        let theme = Theme.map(Product.stub2.theme)
        XCTAssertNoDiff(result.theme.foregroundColor, theme.foregroundColor)
    }

    func test_makeHeaderForProductView() {

        let sut = makeSUT()
        let result = sut.makeHeaderView(with: .stub2)
        XCTAssertNoDiff(result.title, Product.stub2.name)
    }

    func test_makeImageForProductView() {

        let sut = makeSUT()
        let result = sut.makeImageView(with: .stub2)
        XCTAssertNoDiff(result.url, Product.stub2.image)
    }

    func test_makeProductView() {

        let sut = makeSUT()
        let result = sut.makeView(with: .stub2)
        
        XCTAssertNoDiff(result.headerView.title, Product.stub2.name)

        XCTAssertNoDiff(result.termsView.params.amount, Product.stub2.keyMarketingParams.amount)
        XCTAssertNoDiff(result.termsView.params.rate, Product.stub2.keyMarketingParams.rate)
        XCTAssertNoDiff(result.termsView.params.term, Product.stub2.keyMarketingParams.term)

        XCTAssertNoDiff(result.bulletsView.bulletsData.first?.1, Product.stub2.features.list.first?.text)
        XCTAssertNoDiff(result.bulletsView.header, Product.stub2.features.header)

        XCTAssertNoDiff(result.imageView.url, Product.stub2.image)
        
        XCTAssertNotNil(result.footerView)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CollateralLoanLandingShowCaseViewFactory<ContentView, SpinnerView>
    private typealias Product = CollateralLoanLandingShowCaseUIModel.Product
    private typealias Theme = CollateralLoanLandingShowCaseTheme
    
    private func makeSUT() -> SUT {
        .init(
            makeContentView: { EmptyView() as! ContentView },
            makeSpinnerView: { EmptyView() as! SpinnerView }
        )
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

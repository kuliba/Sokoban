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

    func test_make_shouldMakeBulletsViewWithHeader() {

        let sut = makeSUT()
        let anyMessage = anyMessage()
        let stub = Product.makeStub(featuresHeader: anyMessage)

        let result = sut.makeBulletsView(with: stub)

        XCTAssertNoDiff(result.header, anyMessage)
    }
    
    func test_make_shouldMakeTermsViewWithTerms() {

        let sut = makeSUT()
        let rate = anyMessage()
        let amount = anyMessage()
        let term = anyMessage()
        let keyMarketingParams = Product.KeyMarketingParams(rate: rate, amount: amount, term: term)
        let stub = Product.makeStub(keyMarketingParams: keyMarketingParams)
        let result = sut.makeTermsView(with: stub)
        
        let mustBeEqual = [
            (rate, result.params.rate),
            (amount, result.params.amount),
            (term, result.params.term)
        ]
        
        mustBeEqual.forEach { (original, mapped) in
            XCTAssertNoDiff(original, mapped)
        }
    }

    func test_make_shouldMakeFooterViewWithTheme() {

        let sut = makeSUT()
        let theme = ModelTheme.validRandom
        let mappedTheme = theme.map()
        let stub = Product.makeStub(theme: theme)
        let result = sut.makeFooterView(with: stub)
        
        XCTAssertNoDiff(result.theme, mappedTheme)
    }

    func test_make_shouldMakeHeaderViewWithName() {

        let sut = makeSUT()
        let title = anyMessage()
        let stub = Product.makeStub(title: title)
        let result = sut.makeHeaderView(with: stub)
        
        XCTAssertNoDiff(result.title, title)
    }

    func test_make_shouldMakeImageWithURL() {

        let sut = makeSUT()
        let image = anyMessage()
        let stub = Product.makeStub(image: image)
        let result = sut.makeImageView(with: stub)

        XCTAssertNoDiff(result.url, image)
    }

    func test_make_shouldMakeProductViewWithAllComponents() {

        let sut = makeSUT()
        let title = anyMessage()
        let image = anyMessage()
        let rate = anyMessage()
        let amount = anyMessage()
        let term = anyMessage()
        let featuresHeader = anyMessage()
        let theme = ModelTheme.random
        let keyMarketingParams = Product.KeyMarketingParams(rate: rate, amount: amount, term: term)
        
        let stub = Product.makeStub(
            theme: theme,
            title: title,
            image: image,
            keyMarketingParams: keyMarketingParams,
            featuresHeader: featuresHeader
        )
        
        let result = sut.makeView(with: stub)
        
        let mustBeEqual = [
            (title, result.headerView.title),
            (image, result.imageView.url),
            (rate, result.termsView.params.rate),
            (amount, result.termsView.params.amount),
            (term, result.termsView.params.term),
            (featuresHeader, result.bulletsView.header)
        ]
        
        mustBeEqual.forEach { (original, mapped) in
            XCTAssertNoDiff(original, mapped)
        }
        
        XCTAssertNoDiff(theme.map(), result.footerView.theme)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CollateralLoanLandingShowCaseViewFactory<ContentView, SpinnerView>
    private typealias Product = CollateralLoanLandingShowCaseUIModel.Product
    private typealias Theme = CollateralLoanLandingShowCaseTheme
    private typealias ModelTheme = CollateralLoanLandingShowCaseUIModel.Product.Theme
    
    private func makeSUT() -> SUT {
        .init(
            makeContentView: { EmptyView() as! ContentView },
            makeSpinnerView: { EmptyView() as! SpinnerView }
        )
    }
}

fileprivate extension CollateralLoanLandingShowCaseUIModel {

    static let stub = Self(
        products: [Product](repeating: .makeStub(), count: .random(in: 0..<10))
    )
}

fileprivate extension CollateralLoanLandingShowCaseUIModel.Product {
    
    static func makeStub(
        theme: Theme = .random,
        title: String = anyMessage(),
        image: String = anyMessage(),
        keyMarketingParams: KeyMarketingParams = .makeAny(),
        featuresHeader: String = anyMessage()
    ) -> Self {
        
        typealias List = CollateralLoanLandingShowCaseUIModel.Product.Features.List
        
        let list = [List](repeating: .init(bullet: .random(), text: anyMessage()), count: .random(in: 0..<10))
        
        return .init(
            theme: theme,
            name: title,
            terms: anyMessage(),
            landingId: anyMessage(),
            image: image,
            keyMarketingParams: keyMarketingParams,
            features: .init(
                header: featuresHeader,
                list: list
            )
        )
    }
}

fileprivate extension CollateralLoanLandingShowCaseUIModel.Product.KeyMarketingParams {

    static func makeAny() -> Self {
        .init(
            rate: anyMessage(),
            amount: anyMessage(),
            term: anyMessage()
        )
    }
}

fileprivate extension CollateralLoanLandingShowCaseUIModel.Product.Theme {
    
    static var random: Self {
        
        let values: [Self] = [.gray, .white, .unknown]
        let randomIndex = Int.random(in: 0..<values.count)
        return values[randomIndex]
    }
    
    static var validRandom: Self {

        let values: [Self] = [.gray, .white]
        let randomIndex = Int.random(in: 0..<values.count)
        return values[randomIndex]
    }
}

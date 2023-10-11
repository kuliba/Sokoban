//
//  ProductConfigTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 29.06.2023.
//

@testable import ForaBank
import XCTest

final class ProductConfigTests: XCTestCase {
    
    // MARK: - Test Card Config
    
    func test_cardConfig_smallSize() {
        
        let sut = makeSUT(size: .small)
        
        XCTAssertEqual(sut.cardViewConfig.headerLeadingPadding, 29)
        XCTAssertEqual(sut.cardViewConfig.headerTopPadding, 4)
        XCTAssertEqual(sut.cardViewConfig.nameSpacing, 4)
        XCTAssertEqual(sut.cardViewConfig.cardPadding, 8)
        XCTAssertEqual(sut.cardViewConfig.cornerRadius, 8)
        XCTAssertEqual(sut.cardViewConfig.checkPadding, 8)
    }
    
    func test_cardConfig_normalSize() {
        
        let sut = makeSUT(size: .normal)
        
        XCTAssertEqual(sut.cardViewConfig.headerLeadingPadding, 43)
        XCTAssertEqual(sut.cardViewConfig.headerTopPadding, 6.2)
        XCTAssertEqual(sut.cardViewConfig.nameSpacing, 6)
        XCTAssertEqual(sut.cardViewConfig.cardPadding, 12)
        XCTAssertEqual(sut.cardViewConfig.cornerRadius, 12)
        XCTAssertEqual(sut.cardViewConfig.checkPadding, 10)
    }
    
    func test_cardConfig_largeSize() {
        
        let sut = makeSUT(size: .large)
        
        XCTAssertEqual(sut.cardViewConfig.headerLeadingPadding, 43)
        XCTAssertEqual(sut.cardViewConfig.headerTopPadding, 6.2)
        XCTAssertEqual(sut.cardViewConfig.nameSpacing, 6)
        XCTAssertEqual(sut.cardViewConfig.cardPadding, 12)
        XCTAssertEqual(sut.cardViewConfig.cornerRadius, 12)
        XCTAssertEqual(sut.cardViewConfig.checkPadding, 10)
    }
    
    // MARK: - Test BackView Config
    
    func test_backViewConfig() {
        
        let sut = makeSUT()
                
        XCTAssertEqual(sut.backViewConfig.headerLeadingPadding, .offset_12)
        XCTAssertEqual(sut.backViewConfig.headerTopPadding, .offset_12)
        XCTAssertEqual(sut.backViewConfig.headerTrailingPadding, .offset_12)
    }
    
    // MARK: - Test Font Config
    
    func test_fontConfig_smallSize() {
        
        let sut = makeSUT(size: .small)
        
        XCTAssertEqual(sut.fontConfig.nameFontForCard, .textBodyXSR11140())
        XCTAssertEqual(sut.fontConfig.nameFontForHeader, .textBodyXSR11140())
        XCTAssertEqual(sut.fontConfig.nameFontForFooter, .textBodyXSR11140())
    }
    
    func test_fontConfig_normalSize() {
        
        let sut = makeSUT(size: .normal)
        
        XCTAssertEqual(sut.fontConfig.nameFontForCard, .textBodyMR14200())
        XCTAssertEqual(sut.fontConfig.nameFontForHeader, .textBodySR12160())
        XCTAssertEqual(sut.fontConfig.nameFontForFooter, .textBodyMSB14200())
    }
    
    func test_fontConfig_largeSize() {
        
        let sut = makeSUT(size: .large)
        
        XCTAssertEqual(sut.fontConfig.nameFontForCard, .textBodyMR14200())
        XCTAssertEqual(sut.fontConfig.nameFontForHeader, .textBodySR12160())
        XCTAssertEqual(sut.fontConfig.nameFontForFooter, .textBodyMSB14200())
    }
    
    // MARK: - Test Size Config
    
    func test_sizeConfig_smallSize() {
        
        let sut = makeSUT(size: .small)
        
        XCTAssertEqual(sut.sizeConfig.paymentSystemIconSize, .init(width: 20, height: 20))
        XCTAssertEqual(sut.sizeConfig.checkViewSize, .init(width: 16, height: 16))
        XCTAssertEqual(sut.sizeConfig.checkViewImageSize, .init(width: 10, height: 10))
    }
    
    func test_sizeConfig_normalSize() {
        
        let sut = makeSUT(size: .normal)
        
        XCTAssertEqual(sut.sizeConfig.paymentSystemIconSize, .init(width: 28, height: 28))
        XCTAssertEqual(sut.sizeConfig.checkViewSize, .init(width: 18, height: 18))
        XCTAssertEqual(sut.sizeConfig.checkViewImageSize, .init(width: 12, height: 12))
    }
    
    func test_sizeConfig_largeSize() {
        
        let sut = makeSUT(size: .large)
        
        XCTAssertEqual(sut.sizeConfig.paymentSystemIconSize, .init(width: 28, height: 28))
        XCTAssertEqual(sut.sizeConfig.checkViewSize, .init(width: 18, height: 18))
        XCTAssertEqual(sut.sizeConfig.checkViewImageSize, .init(width: 12, height: 12))
    }
    
    // MARK: - Helpers
    private func makeSUT(
        size: ProductView.ViewModel.Appearance.Size = .small,
        cardAction: ProductView.ViewModel.CardAction? = nil,
        showCVV: ProductView.ViewModel.ShowCVV? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ProductView.ViewModel {
        let sut =  ProductView.ViewModel(
            id: 1,
            header: .init(number: "7854"),
            cardInfo: .classicCard,
            footer: .init(balance: "170 897 ₽"),
            statusAction: .init(status: .unblock),
            appearance: .init(
                textColor: .clear,
                background: .init(color: .clear, image: nil),
                size: size),
            isUpdating: false,
            productType: .card,
            cardAction: cardAction,
            showCvv: showCVV
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension CGFloat {
    
    static let offset_12: Self = CGFloat(12).pixelsToPoints()
}

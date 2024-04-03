//
//  ProductConfigTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 29.06.2023.
//

@testable import ForaBank
import XCTest
import SwiftUI
import CardUI

final class ProductConfigTests: XCTestCase {
    
    // MARK: - Test front Config
    
    func test_frontConfig_smallSize() {
        
        let sut = makeSUT(size: .small)
        
        XCTAssertEqual(sut.front.headerLeadingPadding, 29)
        XCTAssertEqual(sut.front.headerTopPadding, 4)
        XCTAssertEqual(sut.front.nameSpacing, 4)
        XCTAssertEqual(sut.front.cardPadding, 8)
        XCTAssertEqual(sut.front.cornerRadius, 8)
        XCTAssertEqual(sut.front.checkPadding, 9.5)
    }
    
    func test_frontConfig_normalSize() {
        
        let sut = makeSUT(size: .normal)
        
        XCTAssertEqual(sut.front.headerLeadingPadding, 43)
        XCTAssertEqual(sut.front.headerTopPadding, 6.2)
        XCTAssertEqual(sut.front.nameSpacing, 6)
        XCTAssertEqual(sut.front.cardPadding, 12)
        XCTAssertEqual(sut.front.cornerRadius, 12)
        XCTAssertEqual(sut.front.checkPadding, 10)
    }
    
    func test_frontConfig_largeSize() {
        
        let sut = makeSUT(size: .large)
        
        XCTAssertEqual(sut.front.headerLeadingPadding, 43)
        XCTAssertEqual(sut.front.headerTopPadding, 6.2)
        XCTAssertEqual(sut.front.nameSpacing, 6)
        XCTAssertEqual(sut.front.cardPadding, 12)
        XCTAssertEqual(sut.front.cornerRadius, 12)
        XCTAssertEqual(sut.front.checkPadding, 10)
    }
    
    // MARK: - Test Back Config
    
    func test_backView() {
        
        let sut = makeSUT()
                
        XCTAssertEqual(sut.back.headerLeadingPadding, .offset_12)
        XCTAssertEqual(sut.back.headerTopPadding, .offset_12)
        XCTAssertEqual(sut.back.headerTrailingPadding, .offset_12)
    }
    
    // MARK: - Test Font Config
    
    func test_fonts_smallSize() {
        
        let sut = makeSUT(size: .small)
        
        XCTAssertEqual(sut.fonts.card, .textBodyXsR11140())
        XCTAssertEqual(sut.fonts.header, .textBodyXsR11140())
        XCTAssertEqual(sut.fonts.footer, .textBodyXsR11140())
    }
    
    func test_fonts_normalSize() {
        
        let sut = makeSUT(size: .normal)
        
        XCTAssertEqual(sut.fonts.card, .textBodyMR14200())
        XCTAssertEqual(sut.fonts.header, .textBodySR12160())
        XCTAssertEqual(sut.fonts.footer, .textBodyMSb14200())
    }
    
    func test_fonts_largeSize() {
        
        let sut = makeSUT(size: .large)
        
        XCTAssertEqual(sut.fonts.card, .textBodyMR14200())
        XCTAssertEqual(sut.fonts.header, .textBodySR12160())
        XCTAssertEqual(sut.fonts.footer, .textBodyMSb14200())
    }
    
    // MARK: - Test Size Config
    
    func test_sizeConfig_smallSize() {
        
        let sut = makeSUT(size: .small)
        
        XCTAssertEqual(sut.sizes.paymentSystemIcon, .init(width: 20, height: 20))
        XCTAssertEqual(sut.sizes.checkView, .init(width: 17, height: 17))
        XCTAssertEqual(sut.sizes.checkViewImage, .init(width: 10, height: 10))
    }
    
    func test_sizeConfig_normalSize() {
        
        let sut = makeSUT(size: .normal)
        
        XCTAssertEqual(sut.sizes.paymentSystemIcon, .init(width: 28, height: 28))
        XCTAssertEqual(sut.sizes.checkView, .init(width: 19, height: 19))
        XCTAssertEqual(sut.sizes.checkViewImage, .init(width: 12, height: 12))
    }
    
    func test_sizeConfig_largeSize() {
        
        let sut = makeSUT(size: .large)
        
        XCTAssertEqual(sut.sizes.paymentSystemIcon, .init(width: 28, height: 28))
        XCTAssertEqual(sut.sizes.checkView, .init(width: 19, height: 19))
        XCTAssertEqual(sut.sizes.checkViewImage, .init(width: 12, height: 12))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        size: CardUI.Appearance.Size = .small,
        textColor: Color = .clear,
        background: Color = .clear,
        backgroundImage: Image? = nil
    ) -> CardUI.Config {
        
        .config(appearance: .init(
            textColor: textColor,
            background: .init(color: background, image: backgroundImage),
            size: size)
        )
    }
}

private extension CGFloat {
    
    static let offset_12: Self = CGFloat(12).pixelsToPoints()
}

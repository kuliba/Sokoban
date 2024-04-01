//
//  CarouselStateTests.swift
//  
//
//  Created by Andryusina Nataly on 01.04.2024.
//

import XCTest
@testable import CarouselComponent

final class CarouselStateTests: XCTestCase {
    
    func test_productType_offsetZero_shouldSetNil(){
        
        let sut = makeSUT(products: .moreProducts)
        
        let productType = sut.productType(with: 0)
        
        XCTAssertNil(productType)
    }

    func test_productType_offsetFirstType_shouldSetFirstType(){
        
        let sut = makeSUT(products: .moreProducts)
        
        let productType = sut.productType(with: 10)
        let firstType = sut.productGroups.first?.productType
        
        XCTAssertNoDiff(productType, firstType)
    }
    
    func test_productType_offsetSecondType_shouldSetSecondType(){
        
        let sut = makeSUT(products: .moreProducts)
        
        let productType = sut.productType(with: 1120)
        let secondType = sut.productGroups[1].productType
        
        XCTAssertNoDiff(productType, secondType)
    }

    func test_productType_offseThirdType_shouldSetThirdType(){
        
        let sut = makeSUT(products: .moreProducts)
        
        let productType = sut.productType(with: 1300)
        let thirdType = sut.productGroups[2].productType
        
        XCTAssertNoDiff(productType, thirdType)
    }

    func test_productType_offsetFourthType_shouldSetFourthType(){
        
        let sut = makeSUT(products: .moreProducts)
        
        let productType = sut.productType(with: 1700)
        let fourthType = sut.productGroups[3].productType
        
        XCTAssertNoDiff(productType, fourthType)
    }

    func test_productType_offsetOutOfRange_shouldSetNil(){
        
        let sut = makeSUT(products: .moreProducts)
        
        let productType = sut.productType(with: 3000)
        
        XCTAssertNil(productType)
    }

    // MARK: - учитываем длину стикера
    
    func test_productType_needShowStickerTrue_shouldSetFirstType(){
        
        let sut = makeSUT(products: [.card, .loan1, .deposit1], needShowSticker: true)
        
        let productType = sut.productType(with: 175)
        let firstType = sut.productGroups[0].productType
        
        XCTAssertNoDiff(productType, firstType)
    }

    func test_productType_needShowStickerFalse_shouldSetSecondType(){
        
        let sut = makeSUT(products: [.card, .loan1, .deposit1], needShowSticker: false)
        
        let productType = sut.productType(with: 175)
        let secondType = sut.productGroups[1].productType
        
        XCTAssertNoDiff(productType, secondType)
    }
    
    private typealias SUT = CarouselState<Product>
    
    private func makeSUT(
        products: [Product] = .allCardProducts,
        needShowSticker: Bool = true
    ) -> SUT {
        
        return .init(
            products: products,
            needShowSticker: needShowSticker
        )
    }
}

//
//  ProductCardTests.swift
//  
//
//  Created by Andryusina Nataly on 05.04.2024.
//

@testable import ProductSelectComponent
import XCTest
import SwiftUI

final class ProductCardTests: XCTestCase {
    
    // MARK: - test set color from string

    func test_init_colorValidWithOutHashMark_shouldSetBackgroundColor() {
        
        let productCard = makeSUT(backgroundColor: "000000")
        XCTAssertNoDiff(productCard.look.backgroundColor, .black)
    }
    
    func test_init_colorValidWithHashMark_shouldSetBackgroundColor() {
        
        let productCard = makeSUT(backgroundColor: "#ff0000")
        XCTAssertNoDiff(productCard.look.backgroundColor, Color(red: 1, green: 0, blue: 0))
    }
    
    func test_init_colorInvalid_shouldSetBackgroundColorToClearColor() {
        
        let productCard = makeSUT(backgroundColor: "778787878787")
        XCTAssertNoDiff(productCard.look.backgroundColor, .clear)
    }

    // MARK: - Helpers

    private func makeSUT(
        backgroundColor: String
    ) -> ProductCard {
        
        .init(product: .init(
            id: 1,
            type: .card,
            isAdditional: false,
            header: "header",
            title: "title",
            footer: "footer",
            amountFormatted: "amount",
            balance: 1,
            look: .init(
                background: .svg(""),
                color: backgroundColor,
                icon: .svg("")
            )))
    }
}

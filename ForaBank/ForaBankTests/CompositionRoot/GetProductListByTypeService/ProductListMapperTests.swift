//
//  ProductListMapperTests.swift
//  ForaBankTests
//
//  Created by Disman Dmitry on 15.03.2024.
//

@testable import ForaBank
import XCTest

final class ProductListMapperTests: XCTestCase {
    
    func test_getProductList_empty_shouldDeliverEmpty() throws {
        
        let emptyResult = ProductListMapper.map(.init(serial: "", productList: []))
        
        XCTAssertNoDiff(emptyResult, .init(serial: "", productList: []))
    }
    
    func test_getProductList_account_shouldDeliverAccount() throws {
        
        let accountResult = ProductListMapper.map(.account)
        
        XCTAssertNoDiff(accountResult, .account)
    }
    
    func test_getProductList_card_shouldDeliverCard() throws {
        
        let cardResult = ProductListMapper.map(.card)
        
        XCTAssertNoDiff(cardResult, .card)
    }
    
    func test_getProductList_deposit_shouldDeliverDeposit() throws {
        
        let depositResult = ProductListMapper.map(.deposit)

        XCTAssertNoDiff(depositResult, .deposit)
    }
    
    func test_getProductList_loan_shouldDeliverDeposit() throws {
        
        let loanResult = ProductListMapper.map(.loan)

        XCTAssertNoDiff(loanResult, .loan)
    }
}

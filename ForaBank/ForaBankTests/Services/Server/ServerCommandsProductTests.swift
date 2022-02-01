//
//  ServerCommandsProductTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 01.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsProductTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsTransferTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    let formatter = DateFormatter.utc

    //MARK: - GetProductDetails
    
    func testGetProductDetails_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetProductDetailsResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.ProductController.GetProductDetails.Response(statusCode: .ok, errorMessage: "string", data: .init(accountNumber: "4081781000000000001", bic: "044525341", corrAccount: "30101810300000000341", inn: "7704113772", kpp: "770401001", payeeName: "Иванов Иван Иванович"))
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductDetails.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }

    //MARK: - GetProductList
    
    func testCreateGetProductList_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetProductListResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = formatter.date(from: "2022-02-01T14:56:20.783Z")!
        let expected = ServerCommands.ProductController.GetProductList.Response(statusCode: .ok, errorMessage: "string", data: [.init(XLDesign: .init(description: "string"), accountNumber: "40817810000000000001", additionalField: "Зарплатная", allowCredit: true, allowDebit: true, background: [.init(description: "FFBB36")], balance: 1000123, branchId: 2000, currency: "RUB", customName: "Моя карта", fontDesignColor: .init(description: "FFFFFF"), id: 10002585800, largeDesign: .init(description: "string"), mainField: "Gold", mediumDesign: .init(description: "string"), number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", openDate: date, ownerID: 10001639855, productName: "VISA REWARDS R-5", productType: .card, smallDesign: .init(description: "string"))])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetProductList_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "GetProductListResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = formatter.date(from: "2022-02-01T14:56:20.783Z")!
        let expected = ServerCommands.ProductController.GetProductList.Response(statusCode: .ok, errorMessage: "string", data: [.init(XLDesign: .init(description: "string"), accountNumber: "40817810000000000001", additionalField: nil, allowCredit: true, allowDebit: true, background: [.init(description: "FFBB36")], balance: 1000123, branchId: 2000, currency: "RUB", customName: nil, fontDesignColor: .init(description: "FFFFFF"), id: 10002585800, largeDesign: .init(description: "string"), mainField: "Gold", mediumDesign: .init(description: "string"), number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", openDate: date, ownerID: 10001639855, productName: "VISA REWARDS R-5", productType: .card, smallDesign: .init(description: "string"))])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetProductListByFilter
    
    func testGetProductListByFilter_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetProductListByFilterResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = formatter.date(from: "2022-02-01T14:56:20.783Z")!
        let expected = ServerCommands.ProductController.GetProductListByFilter.Response(statusCode: .ok, errorMessage: "string", data: [.init(XLDesign: .init(description: "string"), accountNumber: "40817810000000000001", additionalField: "Зарплатная", allowCredit: true, allowDebit: true, background: [.init(description: "FFBB36")], balance: 1000123, branchId: 2000, currency: "RUB", customName: "Моя карта", fontDesignColor: .init(description: "FFFFFF"), id: 10002585800, largeDesign: .init(description: "string"), mainField: "Gold", mediumDesign: .init(description: "string"), number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", openDate: date, ownerID: 10001639855, productName: "VISA REWARDS R-5", productType: .card, smallDesign: .init(description: "string"))])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByFilter.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetProductListByFilter_Response_Decoding_Min() throws {

        // given
        let url = bundle.url(forResource: "GetProductListByFilterResponseMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = formatter.date(from: "2022-02-01T14:56:20.783Z")!
        let expected = ServerCommands.ProductController.GetProductListByFilter.Response(statusCode: .ok, errorMessage: "string", data: [.init(XLDesign: .init(description: "string"), accountNumber: "40817810000000000001", additionalField: nil, allowCredit: true, allowDebit: true, background: [.init(description: "FFBB36")], balance: 1000123, branchId: 2000, currency: "RUB", customName: nil, fontDesignColor: .init(description: "FFFFFF"), id: 10002585800, largeDesign: .init(description: "string"), mainField: "Gold", mediumDesign: .init(description: "string"), number: "4444555566661122", numberMasked: "4444-XXXX-XXXX-1122", openDate: date, ownerID: 10001639855, productName: "VISA REWARDS R-5", productType: .card, smallDesign: .init(description: "string"))])
        
        // when
        let result = try decoder.decode(ServerCommands.ProductController.GetProductListByFilter.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}

//
//  ProductModelTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 14.04.2022.
//

import XCTest
@testable import ForaBank

class ProductModelTests: XCTestCase {

    let model = Model(serverAgent: ServerAgentEmptyMock(), localAgent: LocalAgentEmptyMock(), keychainAgent: KeychainAgentMock(), settingsAgent: SettingsAgentMock(), biometricAgent: BiometricAgentMock())
    
    //MARK: - Handle
    
    func testUpdatedListValue() throws {
        
        // given
        let bundle = Bundle(for: Model.self)
        let url = bundle.url(forResource: "ProductsListSample", withExtension: "json")!
        let json = try! Data(contentsOf: url)
        let decoder = JSONDecoder.serverDate
        let productsData = try! decoder.decode([ProductData].self, from: json)
        
        model.products.value = self.model.reduce(products: model.products.value, with: productsData)
        
        let updated = self.model.updatedListValue(products: model.products.value, with: [.init(id: 10004281479, type: .card, dynamicParams: .init(balance: 100.0, balanceRub: 100.0, customName: "Handle"))])
    
        // when
        let result = updated[.account]?.filter({$0.id == 10004281479}).first?.customName
        
        // then
        XCTAssertEqual(result, "Handle")
    }
}

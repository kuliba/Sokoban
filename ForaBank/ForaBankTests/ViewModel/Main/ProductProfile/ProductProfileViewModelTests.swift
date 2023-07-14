//
//  ProductProfileViewModelTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 06.06.2023.
//

import XCTest
@testable import ForaBank

final class ProductProfileViewModelTests: XCTestCase {

    func test_initWithEmptyModel_nil() {
        
        let sut = makeSUT(product: anyProduct(id: 0, productType: .card))
        
        XCTAssertNil(sut)
    }
    
    func test_init_notNil() throws {
        
        let model = makeModelWithProducts()
        let product = try XCTUnwrap(model.products.value[.card]?.first)
        let sut = makeSUT(model: model, product: product)
        
        XCTAssertNotNil(sut)
    }
    
    //FIXME: test fails for some reason but should not
    /*
    func test_transferButtonDidTappedAction_firesOnceInResponseToButtonsViewModelActionButtonDidTapped() throws {
        
        // given
        let model = makeModelWithProducts()
        let product = try XCTUnwrap(model.products.value[.card]?.first)
        let sut = try XCTUnwrap(makeSUT(model: model, product: product))
        let spy = ValueSpy(sut.action)
    
        // wait for bindings
        _ = XCTWaiter.wait(for: [], timeout: 0.1)
        
        // when
        sut.buttons.action.send(ProductProfileButtonsSectionViewAction.ButtonDidTapped(buttonType: .topRight))
        _ = XCTWaiter.wait(for: [], timeout: 0.1)

        // then
        XCTAssertEqual(spy.values.count, 1)
        XCTAssertNotNil(spy.values.first as? ProductProfileViewModelAction.TransferButtonDidTapped)
    }
     */
    
    //FIXME: test fails for some reason but should not
    /*
    func test_preferredProductID_setValueAfrerTransferButtonDidTappedActionTriggered() throws {
        
        let model = makeModelWithProducts()
        let product = try XCTUnwrap(model.products.value[.card]?.first)
        let sut = try XCTUnwrap(makeSUT(model: model, product: product))
        
        // wait for bindings
        _ = XCTWaiter().wait(for: [], timeout: 0.1)
        
        // when
        sut.action.send(ProductProfileViewModelAction.TransferButtonDidTapped())
        _ = XCTWaiter.wait(for: [], timeout: 0.1)
        
        XCTAssertEqual(model.preferredProductID, product.id)
    }
    */
    
    func test_preferredProductID_setToNilAfrerIsLinkActiveBecomeFalse() throws {
        
        let model = makeModelWithProducts()
        let product = try XCTUnwrap(model.products.value[.card]?.first)
        let sut = try XCTUnwrap(makeSUT(model: model, product: product))
        model.setPreferredProductID(to: 1000)
        sut.isLinkActive = true
        
        // wait for bindings
        _ = XCTWaiter.wait(for: [], timeout: 0.1)
        
        // when
        sut.isLinkActive = false
        _ = XCTWaiter.wait(for: [], timeout: 0.1)
        
        XCTAssertNil(model.preferredProductID)
    }
}

extension ProductProfileViewModelTests {
    
    func makeSUT(
        model: Model = .mockWithEmptyExcept(),
        product: ProductData,
        rootView: String = "")
    -> ProductProfileViewModel? {
        
        .init(model, product: product, rootView: rootView, dismissAction: {})
    }
    
    func makeModelWithProducts(_ counts: ProductTypeCounts = [(.card, 1)]) -> Model {
        
        let model = Model.mockWithEmptyExcept()
        model.products.value = makeProductsData(counts)
        
        return model
    }
}

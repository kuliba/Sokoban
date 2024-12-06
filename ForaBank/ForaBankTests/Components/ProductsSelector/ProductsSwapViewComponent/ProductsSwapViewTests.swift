//
//  ProductsSwapViewTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 18.08.2023.
//
@testable import ForaBank
import XCTest

final class ProductsSwapViewTests: XCTestCase {
    
    // MARK: - test convenience init for template
    
    func test_convenience_init_templateInValid_shouldReturnNil() {
        
        let sut = makeSUT(mode: .templatePayment(0, "This is a template"))
        
        XCTAssertNil(sut)
    }
    
    func test_convenience_init_templateValid_shouldCreateSwapButton() throws {
        
        let sut = try XCTUnwrap(makeSUT(mode: .templatePayment(1, "This is a template")))
        
        XCTAssertNotNil(sut.divider)
        XCTAssertNotNil(sut.divider.swapButton)
    }
    
    // MARK: Helpers
    
    private func makeSUT(
        mode: PaymentsMeToMeViewModel.Mode
    ) -> ProductsSwapView.ViewModel? {
        
        let model = Model.mockWithEmptyExcept()
        
        model.paymentTemplates.value = [
            .templateStub(
                paymentTemplateId: 1,
                type: .betweenTheir)
        ]
        
        model.products.value = [.card: [.stub(productId: 1)]]
        
        let sut = ProductsSwapView.ViewModel(
            model,
            mode: mode
        )
        
        return sut
    }
}

//
//  PaymentsProductViewModelTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 25.09.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsProductViewModelTests: XCTestCase {
    
    func test_init_shouldSetSelectorContentToPlaceholder() {
        
        let (sut, _) = makeSUT()
        let contentSpy = ValueSpy(sut.selector.$content.map(\.case))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(contentSpy.values, [.placeholder])
    }
    
    func test_init_shouldSetValue() {
        
        let (sut, _) = makeSUT()
        let valueSpy = ValueSpy(sut.$value)
        
        XCTAssertNoDiff(valueSpy.values, [
            product(last: "1", current: "1")
        ])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(valueSpy.values, [
            product(last: "1", current: "1"),
            product(last: "1", current: nil),
        ])
    }
    
    func test_selector_content_changeShouldSetSelectorContentToPlaceholder() {
        
        let (sut, _) = makeSUT()
        let contentSpy = ValueSpy(sut.selector.$content.map(\.case))
        XCTAssertNoDiff(contentSpy.values, [
            .placeholder,
        ])
        
        sut.selector.content = .product(.sample1)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(contentSpy.values, [
            .placeholder,
            .product
        ])
    }
    
    func test_selector_content_changeShouldSetValue() {
        
        let (sut, _) = makeSUT()
        let valueSpy = ValueSpy(sut.$value)
        
        XCTAssertNoDiff(valueSpy.values, [
            product(last: "1", current: "1")
        ])
        
        sut.selector.content = .product(.sample1)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(valueSpy.values, [
            product(last: "1", current: "1"),
            product(last: "1", current: nil),
            product(last: nil, current: "10002585801")
        ])
    }
    
    func test_update_shouldSetSelectorContentToPlaceholder_onMissing() {
        
        let source = parameterProductStub(value: "123")
        let (sut, model) = makeSUT()
        let contentSpy = ValueSpy(sut.selector.$content.map(\.case))
        XCTAssertNoDiff(contentSpy.values, [
            .placeholder,
        ])
        
        sut.update(source: source)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(contentSpy.values, [
            .placeholder,
        ])
        XCTAssertNil(model.firstProduct(with: source.filter))
    }
    
    func test_update_shouldSetValue_onMissing() {
        
        let source = parameterProductStub(value: "123")
        let (sut, model) = makeSUT()
        let valueSpy = ValueSpy(sut.$value)
        
        XCTAssertNoDiff(valueSpy.values, [
            product(last: "1", current: "1")
        ])
        
        sut.update(source: source)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(valueSpy.values, [
            product(last: "1", current: "1"),
            product(last: "1", current: "1"),
            product(last: "1", current: nil),
        ])
        XCTAssertNil(model.firstProduct(with: source.filter))
    }
    
    func test_update_shouldSetSelectorContentToPlaceholder_onProduct() {
        
        let source = parameterProductStub(value: "123")
        let (sut, model) = makeSUT()
        let products = makeProductsData([(.account, 1)])
        model.products.value = products
        let contentSpy = ValueSpy(sut.selector.$content.map(\.case))
        XCTAssertNoDiff(contentSpy.values, [
            .placeholder,
        ])
        
        sut.update(source: source)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(contentSpy.values, [
            .placeholder,
        ])
        XCTAssertNotNil(model.firstProduct(with: source.filter))
    }
    
    func test_update_shouldSetValue_onProduct() {
        
        let source = parameterProductStub(value: "123")
        let (sut, model) = makeSUT()
        let products = makeProductsData([(.account, 1)])
        model.products.value = products
        let valueSpy = ValueSpy(sut.$value)
        
        XCTAssertNoDiff(valueSpy.values, [
            product(last: "1", current: "1")
        ])
        
        sut.update(source: source)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(valueSpy.values, [
            product(last: "1", current: "1"),
            product(last: "1", current: "1"),
            product(last: "1", current: nil),
        ])
        XCTAssertNotNil(model.firstProduct(with: source.filter))
    }
    
    func test_update_shouldNotChangeSelectorContent_onNonParameterProductSource() {
        
        let nonParameterProduct = Payments.ParameterMosParking(value: "abc")
        let (sut, _) = makeSUT()
        let contentSpy = ValueSpy(sut.selector.$content.map(\.case))
        XCTAssertNoDiff(contentSpy.values, [.placeholder,])
        
        sut.update(source: nonParameterProduct)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(contentSpy.values, [.placeholder,])
    }
    
    func test_update_shouldNotChangeValue_onNonParameterProductSource() {
        
        let nonParameterProduct = Payments.ParameterMosParking(value: "abc")
        let (sut, _) = makeSUT()
        let valueSpy = ValueSpy(sut.$value)
        
        XCTAssertNoDiff(valueSpy.values, [
            product(last: "1", current: "1")
        ])
        
        sut.update(source: nonParameterProduct)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(valueSpy.values, [
            product(last: "1", current: "1"),
            product(last: "1", current: "abc"),
            product(last: "abc", current: nil)
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        additional: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: PaymentsProductView.ViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sut = PaymentsProductView.ViewModel(
            model,
            parameterProduct: parameterProductStub(
                additional: additional
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    private func parameterProductStub(
        value: String? = nil,
        additional: Bool = false
    ) -> Payments.ParameterProduct {
        
        .init(
            with: .init(
                id: "id",
                value: value,
                title: "title",
                filter: .init(
                    productTypes: [.account],
                    currencies: [.rub],
                    additional: additional
                )),
            product: .stub()
        )
    }
    
    private func product(
        last: String?,
        current: String?
    ) -> PaymentsParameterViewModel.Value {
        
        .init(
            id: "ru.forabank.sense.product",
            last: last,
            current: current
        )
    }
}

private extension ProductSelectorView.ViewModel.Content {
    
    var `case`: Case {
        
        switch self {
            
        case .product:
            return .product
        case .placeholder:
            return .placeholder
        }
    }
    
    enum Case {
        
        case product, placeholder
    }
}

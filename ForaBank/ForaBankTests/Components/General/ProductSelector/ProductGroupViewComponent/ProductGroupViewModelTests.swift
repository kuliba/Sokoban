//
//  ProductGroupViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.02.2023.
//

@testable import ForaBank
import XCTest

final class ProductGroupViewModelTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetIsCollapsedToTrue_onEmpty() {
        
        let sut = makeSUT()
        
        XCTAssertEqual(sut.isCollapsed, true)
    }
    
    func test_init_shouldSetIsCollapsedToTrue_onNonEmpty() {
        
        let sut = makeSUT(products: makeProductViewVMs(count: 10))
        
        XCTAssertEqual(sut.isCollapsed, true)
    }
    
    func test() {
        
        let sut = makeSUT(products: makeProductViewVMs(count: 10))
        
        sut.action.send(ProductGroupAction.GroupButtonDidTapped())
        
        XCTAssertEqual(sut.isCollapsed, true)
    }
    
    func test_init_shouldSetVisibleProductsAccordingToSettings() {
        
        let productsCount = 10
        let visibleCount = 5
        let sut = makeSUT(
            productsCount: productsCount,
            visibleCount: visibleCount
        )
        let visible = ValueSpy(sut.$visible)
        
        XCTAssertEqual(visible.values.map(\.count), [0])
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(
            visible.values.map(\.count),
            [0, visibleCount, visibleCount]
        )
        XCTAssertEqual(
            visible.values.map { $0.map(\.id) }, [
                [],
                [0, 1, 2, 3, 4],
                [0, 1, 2, 3, 4],
            ])
    }
    
    func test_init_shouldHideGroupButtonWhenProductCountIsLessThanVisible() {
        
        let productsCount = 4
        let visibleCount = 5
        let sut = makeSUT(
            productsCount: productsCount,
            visibleCount: visibleCount
        )
        let visible = ValueSpy(sut.$groupButton)
        XCTAssertEqual(
            visible.values.map { $0.map(\.content) },
            [nil]
        )
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(
            visible.values.map { $0.map(\.content) },
            [nil, nil, nil]
        )
        XCTAssertLessThan(productsCount, visibleCount)
    }
    
    func test_init_shouldHideGroupButtonWhenProductCountIsEqualThanVisible() {
        
        let productsCount = 4
        let visibleCount = 4
        let sut = makeSUT(
            productsCount: productsCount,
            visibleCount: visibleCount
        )
        let visible = ValueSpy(sut.$groupButton)
        XCTAssertEqual(
            visible.values.map { $0.map(\.content) },
            [nil]
        )
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(
            visible.values.map { $0.map(\.content) },
            [nil, nil, nil]
        )
        XCTAssertEqual(productsCount, visibleCount)
    }
    
    func test_init_shouldShowGroupButtonWhenProductCountIsGreaterThanVisible() {
        
        let productsCount = 6
        let visibleCount = 4
        let sut = makeSUT(
            productsCount: productsCount,
            visibleCount: visibleCount
        )
        let visible = ValueSpy(sut.$groupButton)
        XCTAssertEqual(
            visible.values.map { $0.map(\.content) },
            [nil]
        )
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(
            visible.values.map { $0.map(\.content) },
            [nil, .title("+2"), .title("+2")]
        )
        XCTAssertGreaterThan(productsCount, visibleCount)
    }
    
    func test_id_shouldMatchProductType() {
        
        ProductType.allCases.forEach { productType in
            
            let sut = makeSUT(productType: productType)
            
            XCTAssertEqual(
                sut.id,
                productType.rawValue,
                "Expected id \"\(sut.id)\", got \"\(productType.rawValue)\" instead."
            )
        }
    }
    
    // MARK: - Width
    
    func test_init_width_regular() {
        let sut = makeSUT(dimensions: .regular)
        
        XCTAssertEqual(sut.width, 9)
    }
    
    func test_init_width_small() {
        let sut = makeSUT(dimensions: .small)
        
        XCTAssertEqual(sut.width, 9)
    }
    
    func test_width_onEmpty_regular() {
        let sut = makeSUT(dimensions: .regular)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.width, 9, "Empty group should be 9pt wide.")
    }
    
    func test_width_onEmpty_small() {
        let sut = makeSUT(dimensions: .small)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.width, 9, "Empty group should be 9pt wide.")
    }
    
    func test_width_withoutGroupButton_regular() {
        let visibleCount = 3
        let sut = makeSUT(
            productsCount: 3,
            visibleCount: visibleCount,
            dimensions: .regular
        )
        XCTAssertEqual(sut.width, 9)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let productsWidth = visibleCount * 164
        let spacingWidth = (visibleCount - 1) * 8
        
        XCTAssertEqual(sut.width, Double(9 + productsWidth + spacingWidth))
        XCTAssertEqual(sut.width, 517)
        XCTAssertNil(sut.groupButton)
    }
    
    func test_width_withoutGroupButton_small() {
        let visibleCount = 3
        let sut = makeSUT(
            productsCount: visibleCount,
            visibleCount: 3,
            dimensions: .small
        )
        XCTAssertEqual(sut.width, 9)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let productsWidth = visibleCount * 112
        let spacingWidth = (visibleCount - 1) * 8
        
        XCTAssertEqual(sut.width, Double(9 + productsWidth + spacingWidth))
        XCTAssertEqual(sut.width, 361)
        XCTAssertNil(sut.groupButton)
    }
    
    func test_width_withGroupButton_regular() {
        let visibleCount = 3
        let sut = makeSUT(
            productsCount: 5,
            visibleCount: visibleCount,
            dimensions: .regular
        )
        XCTAssertEqual(sut.width, 9)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let productsWidth = visibleCount * 164
        let spacingWidth = (visibleCount - 1) * 8
        let buttonWithSpacing = 48 + 8
        
        XCTAssertEqual(sut.width, Double(9 + productsWidth + spacingWidth + buttonWithSpacing))
        XCTAssertEqual(sut.width, 573)
        XCTAssertNotNil(sut.groupButton)
    }
    
    func test_width_withGroupButton_small() {
        let visibleCount = 3
        let sut = makeSUT(
            productsCount: 5,
            visibleCount: visibleCount,
            dimensions: .small
        )
        XCTAssertEqual(sut.width, 9)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let productsWidth = visibleCount * 112
        let spacingWidth = (visibleCount - 1) * 8
        let buttonWithSpacing = 40 + 8
        
        XCTAssertEqual(sut.width, Double(9 + productsWidth + spacingWidth + buttonWithSpacing))
        XCTAssertEqual(sut.width, 409)
        XCTAssertNotNil(sut.groupButton)
    }
    
    func test_width_expanded_regular() {
        let productsCount = 5
        let sut = makeSUT(
            productsCount: productsCount,
            visibleCount: 3,
            dimensions: .regular
        )
        XCTAssertEqual(sut.width, 9)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        sut.expand()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let productsWidth = productsCount * 164
        let spacingWidth = (productsCount - 1) * 8
        let buttonWithSpacing = 48 + 8
        
        XCTAssertEqual(sut.width, Double(9 + productsWidth + spacingWidth + buttonWithSpacing))
        XCTAssertEqual(sut.width, 917)
        XCTAssertEqual(sut.visible.count, productsCount)
        XCTAssertEqual(sut.groupButton?.content, .icon(.ic24ChevronsLeft))
    }
    
    func test_width_expanded_small() {
        let productsCount = 5
        let sut = makeSUT(
            productsCount: productsCount,
            visibleCount: 3,
            dimensions: .small
        )
        XCTAssertEqual(sut.width, 9)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        sut.expand()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let productsWidth = productsCount * 112
        let spacingWidth = (productsCount - 1) * 8
        let buttonWithSpacing = 40 + 8
        
        XCTAssertEqual(sut.width, Double(9 + productsWidth + spacingWidth + buttonWithSpacing))
        XCTAssertEqual(sut.width, 649)
        XCTAssertEqual(sut.visible.count, productsCount)
        XCTAssertEqual(sut.groupButton?.content, .icon(.ic24ChevronsLeft))
    }
    
    func test_width_onEmptyWithIsOpeningProduct_regular() {
        let sut = makeSUT(dimensions: .regular)
        sut.isOpeningProduct = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.width, Double(9 + 164))
        XCTAssertEqual(sut.width, 173)
        XCTAssert(sut.isOpeningProduct)
    }
    
    func test_width_onEmptyWithIsOpeningProduct_small() {
        let sut = makeSUT(dimensions: .small)
        sut.isOpeningProduct = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.width, Double(9 + 112))
        XCTAssertEqual(sut.width, 121)
        XCTAssert(sut.isOpeningProduct)
    }
    
    func test_width_withoutGroupButton_withIsOpeningProduct_regular() {
        let count = 3
        let sut = makeSUT(
            productsCount: count,
            visibleCount: 3,
            dimensions: .regular
        )
        sut.isOpeningProduct = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let productsWidth = count * 164
        let spacingWidth = (count - 1) * 8
        
        XCTAssertEqual(sut.width, Double(9 + productsWidth + spacingWidth + 164))
        XCTAssertEqual(sut.width, 681)
        XCTAssertNil(sut.groupButton)
        XCTAssert(sut.isOpeningProduct)
    }
    
    func test_width_withoutGroupButton_withIsOpeningProduct_small() {
        let count = 3
        let sut = makeSUT(
            productsCount: count,
            visibleCount: count,
            dimensions: .small
        )
        sut.isOpeningProduct = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let productsWidth = count * 112
        let spacingWidth = (count - 1) * 8
        
        XCTAssertEqual(sut.width, Double(9 + productsWidth + spacingWidth + 112))
        XCTAssertEqual(sut.width, 473)
        XCTAssertNil(sut.groupButton)
        XCTAssert(sut.isOpeningProduct)
    }
    
    func test_width_withGroupButton_withIsOpeningProduct_regular() {
        let visibleCount = 3
        let sut = makeSUT(
            productsCount: 5,
            visibleCount: visibleCount,
            dimensions: .regular
        )
        sut.isOpeningProduct = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let productsWidth = visibleCount * 164
        let spacingWidth = (visibleCount - 1) * 8
        let buttonWithSpacing = 48 + 8
        
        XCTAssertEqual(sut.width, Double(9 + productsWidth + spacingWidth + buttonWithSpacing + 164))
        XCTAssertEqual(sut.width, 737)
        XCTAssertNotNil(sut.groupButton)
        XCTAssert(sut.isOpeningProduct)
    }
    
    func test_width_withGroupButton_withIsOpeningProduct_small() {
        let visibleCount = 3
        let sut = makeSUT(
            productsCount: 5,
            visibleCount: visibleCount,
            dimensions: .small
        )
        sut.isOpeningProduct = true

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let productsWidth = visibleCount * 112
        let spacingWidth = (visibleCount - 1) * 8
        let buttonWithSpacing = 40 + 8
        
        XCTAssertEqual(sut.width, Double(9 + productsWidth + spacingWidth + buttonWithSpacing + 112))
        XCTAssertEqual(sut.width, 521)
        XCTAssertNotNil(sut.groupButton)
        XCTAssert(sut.isOpeningProduct)
    }
    
    // MARK: - products update
    
    func test_update_shouldChangeVisibleProductsToAvailable() {
        
        let productsCount = 10
        let visibleCount = 5
        let sut = makeSUT(
            productsCount: productsCount,
            visibleCount: visibleCount
        )
        let visible = ValueSpy(sut.$visible)
        
        let newProductsCount = 2
        sut.update(with: makeProductViewVMs(count: newProductsCount))
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(
            visible.values.map(\.count),
            [0, visibleCount, visibleCount, newProductsCount]
        )
        XCTAssertEqual(
            visible.values.map { $0.map(\.id) }, [
                [],
                [0, 1, 2, 3, 4],
                [0, 1, 2, 3, 4],
                [0, 1],
            ])
        XCTAssertEqual(visible.events.count, 4)
        XCTAssertEqual(sut.isCollapsed, true)
    }
    
    func test_update_shouldHideGroupButtonWhenNewProductCountIsLessThanVisible() {
        
        let productsCount = 6
        let visibleCount = 5
        let sut = makeSUT(
            productsCount: productsCount,
            visibleCount: visibleCount
        )
        let visible = ValueSpy(sut.$groupButton)
        
        let newProductsCount = 2
        sut.update(with: makeProductViewVMs(count: newProductsCount))
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(
            visible.values.map { $0.map(\.content) },
            [nil, .title("+1"), .title("+1"), nil]
        )
        XCTAssertLessThan(newProductsCount, visibleCount)
    }
    
    func test_update_shouldHideGroupButtonWhenNewProductCountIsEqualThanVisible() {
        
        let productsCount = 5
        let visibleCount = 4
        let sut = makeSUT(
            productsCount: productsCount,
            visibleCount: visibleCount
        )
        let visible = ValueSpy(sut.$groupButton)
        
        let newProductsCount = 4
        sut.update(with: makeProductViewVMs(count: newProductsCount))
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(
            visible.values.map { $0.map(\.content) },
            [nil, .title("+1"), .title("+1"), nil]
        )
        XCTAssertEqual(newProductsCount, visibleCount)
    }
    
    func test_update_shouldShowGroupButtonWhenNewProductCountIsGreaterThanVisible() {
        
        let productsCount = 3
        let visibleCount = 4
        let sut = makeSUT(
            productsCount: productsCount,
            visibleCount: visibleCount
        )
        let visible = ValueSpy(sut.$groupButton)
        
        let newProductsCount = 5
        sut.update(with: makeProductViewVMs(count: newProductsCount))
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(
            visible.values.map { $0.map(\.content) },
            [nil, nil, nil, .title("+1")]
        )
        XCTAssertGreaterThan(newProductsCount, visibleCount)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        productsCount: Int,
        visibleCount: Int,
        dimensions: ProductGroupView.ViewModel.Dimensions = .regular,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ProductGroupView.ViewModel {
        
        let productType: ProductType = .card
        let products = makeProductViewVMs(count: productsCount)
        let settings = ProductsGroupSettings(
            minVisibleProductsAmount: visibleCount
        )
        let model: Model = .productsMock
        
        let sut = makeSUT(
            productType: productType,
            products: products,
            settings: settings,
            dimensions: dimensions,
            model: model
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeSUT(
        productType: ProductType = .card,
        products: [ProductViewModel] = [],
        settings: ProductsGroupSettings = .base,
        dimensions: ProductGroupView.ViewModel.Dimensions = .regular,
        model: Model = .productsMock,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ProductGroupView.ViewModel {
        
        let sut = ProductGroupView.ViewModel(
            productType: productType,
            products: products,
            settings: settings,
            dimensions: dimensions,
            model: model
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

// MARK: - DSL

private extension ProductGroupView.ViewModel {
    
    func expand() {
        
        groupButton?.action()
    }
}

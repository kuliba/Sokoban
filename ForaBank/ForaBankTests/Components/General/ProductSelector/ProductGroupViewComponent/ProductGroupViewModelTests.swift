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
    
    // MARK: - needSeparator https://shorturl.at/hATDx
    
    func test_needSeparator_p2_returnTrue() {
        
        let products: [ProductViewModel] = [
            .createViewModel(id: 2, productType: .card),
            .createViewModel(id: 21, productType: .card),
            .createViewModel(id: 22, productType: .card),
            .createViewModel(id: 1, productType: .card),
        ]
        let sut = makeSUT(visibleProducts: products, getProduct: getProduct(_:))
        
        XCTAssertTrue(sut.needSeparator(for: 2))
    }
    
    func test_needSeparator_p3_returnFalse() {
        
        let products: [ProductViewModel] = [
            .createViewModel(id: 2, productType: .card),
            .createViewModel(id: 21, productType: .card),
            .createViewModel(id: 22, productType: .card)
        ]
        let sut = makeSUT(visibleProducts: products, getProduct: getProduct(_:))
        
        XCTAssertFalse(sut.needSeparator(for: 2))
    }
    
    func test_needSeparator_p4_returnFalse() {
        
        let products: [ProductViewModel] = [
            .createViewModel(id: 1, productType: .card),
            .createViewModel(id: 2, productType: .card),
        ]
        let sut = makeSUT(visibleProducts: products, getProduct: getProduct(_:))
        
        XCTAssertFalse(sut.needSeparator(for: 0))
    }

    func test_needSeparator_p5_returnTrue() {
        
        let products: [ProductViewModel] = [
            .createViewModel(id: 1, productType: .card),
            .createViewModel(id: 41, productType: .card),
            .createViewModel(id: 42, productType: .card),
            .createViewModel(id: 2, productType: .card),
        ]
        let sut = makeSUT(visibleProducts: products, getProduct: getProduct(_:))
        
        XCTAssertTrue(sut.needSeparator(for: 2))
    }
    
    func test_needSeparator_p6_returnTrue() {
        
        let products: [ProductViewModel] = [
            .createViewModel(id: 1, productType: .card),
            .createViewModel(id: 41, productType: .card),
            .createViewModel(id: 51, productType: .card),
            .createViewModel(id: 2, productType: .card),
        ]
        let sut = makeSUT(visibleProducts: products, getProduct: getProduct(_:))
        
        XCTAssertTrue(sut.needSeparator(for: 0))
        XCTAssertTrue(sut.needSeparator(for: 1))
        XCTAssertTrue(sut.needSeparator(for: 2))
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
    
    private func makeSUT(
        productType: ProductType = .card,
        visibleProducts: [ProductViewModel],
        dimensions: ProductGroupView.ViewModel.Dimensions = .regular,
        model: Model = .productsMock,
        getProduct: @escaping ProductGroupView.ViewModel.GetProduct,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ProductGroupView.ViewModel {
        
        let sut = ProductGroupView.ViewModel(
            productType: productType,
            visible: visibleProducts,
            groupButton: nil,
            isCollapsed: false,
            isSeparator: false,
            isUpdating: false,
            isOpeningProduct: false,
            dimensions: .regular,
            getProduct: getProduct
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func getProduct(_ id: ProductData.ID) -> ProductCardData? {
        
        let cards: [ProductData] = .cards
        
        return cards.first(where: { $0.id == id })?.asCard
    }
}

// MARK: - DSL

private extension ProductGroupView.ViewModel {
    
    func expand() {
        
        groupButton?.action()
    }
}

private extension ProductData {
    
    static func makeCardProduct(
        id: Int,
        parentID: Int? = nil,
        cardType: ProductCardData.CardType
    ) -> ProductCardData {
        
        .init(
            id: id,
            productType: .card,
            number: "1111",
            numberMasked: "****",
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "RUB",
            mainField: "Card",
            additionalField: nil,
            customName: nil,
            productName: "Card",
            openDate: nil,
            ownerId: 0,
            branchId: 0,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: .test,
            largeDesign: .test,
            mediumDesign: .test,
            smallDesign: .test,
            fontDesignColor: .init(description: ""),
            background: [],
            accountId: nil,
            cardId: 0,
            name: "CARD",
            validThru: Date(),
            status: .active,
            expireDate: "01/01/01",
            holderName: "Иванов",
            product: nil,
            branch: "",
            miniStatement: nil,
            paymentSystemName: nil,
            paymentSystemImage: nil,
            loanBaseParam: nil,
            statusPc: nil,
            isMain: nil,
            externalId: nil,
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "",
            cardType: cardType, 
            idParent: parentID
        )
    }

}

private extension Array where Element == ProductData {
    
    static let cards: Self = [
        .makeCardProduct(id: 1, cardType: .regular),
        .makeCardProduct(id: 2, cardType: .main),
        .makeCardProduct(id: 21, parentID: 2, cardType: .additionalSelf),
        .makeCardProduct(id: 22, parentID: 2, cardType: .additionalOther),
        .makeCardProduct(id: 3, cardType: .main),
        .makeCardProduct(id: 31, parentID: 3, cardType: .additionalSelf),
        .makeCardProduct(id: 41, parentID: 4, cardType: .additionalSelfAccOwn),
        .makeCardProduct(id: 42, parentID: 4, cardType: .additionalSelf),
        .makeCardProduct(id: 51, parentID: 5, cardType: .additionalOther)
    ]
}

private extension ProductViewModel {
    
    static func createViewModel(
        id: ProductData.ID,
        productType: ProductType = .card
    ) -> ProductViewModel {
        
        .init(
            id: id,
            header: .init(number: nil),
            cardInfo: .classicCard,
            footer: .init(balance: "1"),
            statusAction: nil,
            appearance: .init(background: .init(color: .black, image: nil), colors: .init(text: .accentColor, checkBackground: .black)),
            isUpdating: false,
            productType: productType
        )
    }
}

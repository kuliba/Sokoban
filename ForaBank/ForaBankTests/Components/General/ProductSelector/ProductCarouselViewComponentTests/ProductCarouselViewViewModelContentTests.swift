//
//  ProductCarouselViewViewModelContentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.02.2023.
//

@testable import ForaBank
import XCTest

final class ProductCarouselViewViewModelContentTests: XCTestCase {
    
    typealias ViewModel = ProductCarouselView.ViewModel
    
    // MARK: - firstGroup
    
    func test_firstGroup_shouldReturnNil_onEmpty() {
        
        let content: ViewModel.Content = .empty
        
        XCTAssertNil(content.firstGroup)
    }
    
    func test_firstGroup_shouldReturnNil_onPlaceholders() {
        
        let content: ViewModel.Content = .placeholders
        
        XCTAssertNil(content.firstGroup)
    }
    
    func test_firstGroup_shouldReturnNil_onEmptyGroups() {
        
        let content: ViewModel.Content = .groups([])
        
        XCTAssertNil(content.firstGroup)
    }
    
    func test_firstGroup_shouldReturnFirst_onNonEmptyGroups() {
        
        let content: ViewModel.Content = .groups(makeGroups(productTypesCounts: [(.card, 2)]))
        
        XCTAssertEqual(content.firstGroup?.id, "CARD")
    }
    
    // MARK: - firstGroup(ofType:)
    
    func test_firstGroupOfType_shouldReturnNil_onEmpty() {
        
        let content: ViewModel.Content = .empty
        
        XCTAssertNil(content.firstGroup(ofType: .card))
    }
    
    func test_firstGroupOfType_shouldReturnNil_onPlaceholders() {
        
        let content: ViewModel.Content = .placeholders
        
        XCTAssertNil(content.firstGroup(ofType: .card))
    }
    
    func test_firstGroupOfType_shouldReturnNil_onEmptyGroups() {
        
        let content: ViewModel.Content = .groups([])
        
        XCTAssertNil(content.firstGroup(ofType: .card))
    }
    
    func test_firstGroupOfType_shouldReturnFirst_onMissingInGroups() {
        
        let content: ViewModel.Content = .groups(makeGroups(productTypesCounts: [(.card, 2)]))
        
        XCTAssertNil(content.firstGroup(ofType: .account)?.id)
    }
    
    func test_firstGroupOfType_shouldReturnFirst_onGroups() {
        
        let content: ViewModel.Content = .groups(makeGroups(productTypesCounts: [(.card, 2)]))
        
        XCTAssertEqual(content.firstGroup(ofType: .card)?.id, "CARD")
    }
    
    func test_sticker_shouldBeNilOnEmptyStickerBannersMyProductList()  {
        
        let (sut, model) = makeSUT()
        
        XCTAssertNil(sut.stickerViewModel)
        XCTAssertNoDiff(model.productListBannersWithSticker.value, [])
    }
    
    // MARK: - Helpers
    
    typealias productVM = ProductCarouselView.ViewModel
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: productVM,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sut = ProductCarouselView.ViewModel(mode: .main, style: .regular, model: .emptyMock)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, model)
    }
    
    private func makeSUTProdVM(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ProductViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sut = ProductViewModel(with: .stub(), size: .normal, style: .main, model: .emptyMock)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, model)
    }
    
    typealias ProductTypeCounts = [(ProductType, Int)]

    private func makeGroups(
        productTypesCounts: ProductTypeCounts
    ) -> [ProductGroupView.ViewModel] {
        
        productTypesCounts.map { (productType, count) in

            let productsData: [ProductData] = makeProducts(count: count, ofType: productType)
            let products: [ProductViewModel] = productsData.map(makeProductViewVM)
            
            return .init(
                productType: productType,
                products: products,
                dimensions: .regular,
                model: .emptyMock
            )
        }
    }
    
    // MARK: - Test Helpers
    
    func test_makeGroups_shouldReturnEmpty_onEmpty() {
        
        let counts: ProductTypeCounts = []
        
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.id),
            []
        )
    }
    
    func test_makeGroups_shouldReturnOneCardGroup_onCards() {
        
        let counts: ProductTypeCounts = [(.card, 5)]
        
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.id),
            ["CARD"]
        )
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.productType),
            [.card]
        )
    }
    
    func test_makeGroups_shouldReturnTwoGroup_onTwoTypes() {
        let counts: ProductTypeCounts = [(.card, 5), (.account, 9)]
        
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.id),
            ["CARD", "ACCOUNT"]
        )
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.productType),
            [.card, .account]
        )
    }
        
    func test_makeGroups_shouldPreserveOrder() {
        
        let counts: ProductTypeCounts = [(.account, 9), (.card, 5)]
        
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.id),
            ["ACCOUNT", "CARD"]
        )
        XCTAssertEqual(
            makeGroups(productTypesCounts: counts).map(\.productType),
            [.account, .card]
        )
    }
    
    #warning("add tests for products inside group")
}

private extension ProductCarouselViewViewModelContentTests {
    
    static let cardIsMainFalse: ProductCardData = ProductCardData(id: 22, currency: .usd, isMain: false)
    static let cardIsMainTrue = ProductCardData(id: 21, currency: .usd)
}

private extension ProductCardData {
    
    convenience init(id: Int, currency: Currency, ownerId: Int = 0, allowCredit: Bool = true, allowDebit: Bool = true, status: ProductData.Status = .active, loanBaseParam: ProductCardData.LoanBaseParamInfoData? = nil, statusPc: ProductData.StatusPC = .active, isMain: Bool = true) {
        
        self.init(id: id, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: currency.description, mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: ownerId, branchId: nil, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], accountId: nil, cardId: 0, name: "", validThru: Date(), status: status, expireDate: nil, holderName: nil, product: nil, branch: "", miniStatement: nil, paymentSystemName: nil, paymentSystemImage: nil, loanBaseParam: loanBaseParam, statusPc: statusPc, isMain: isMain, externalId: nil, order: 0, visibility: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
    }
}

//
//  XCTestCase+ext.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.02.2023.
//

@testable import ForaBank
import XCTest

extension XCTestCase {
    
    // MARK: - Helpers
    
    func assert<T: Equatable>(
        _ received: [T],
        equals partial: inout [T],
        appending: T...,
        message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        partial += appending
        XCTAssertNoDiff(received, partial, message(), file: file, line: line)
    }
    
    typealias ProductTypeCounts = [(ProductType, Int)]

    func makeProductViewVMs(count: Int) -> [ProductView.ViewModel] {
        
        let productsData = makeProductsData([(.card, count)])
        return makeProductViewVMs(from: productsData)
    }
    
    func makeProductViewVMs(
        from productsData: ProductsData
    ) -> [ProductView.ViewModel] {
        
        productsData
            .values
            .flatMap { $0 }
            .map(makeProductViewVM)
    }
    
    func makeProductViewVM(
        from productData: ProductData
    ) -> ProductView.ViewModel {
        
        .init(
            with: productData,
            size: .normal,
            style: .main,
            model: .emptyMock
        )
    }
    
    func makeProductsData(
        _ counts: ProductTypeCounts = []
    ) -> ProductsData {
        
        let products = counts.flatMap { productType, count in
            makeProducts(count: count, ofType: productType)
        }
        
        return Dictionary(grouping: products, by: \.productType)
    }
    
    func makeProducts(
        count: Int,
        ofType productType: ProductType
    ) -> [ProductData] {
        
        productType.testIDRange(for: count).map {
            anyProduct(id: $0, productType: productType)
        }
    }
    
    func anyProduct(
        id: Int,
        productType: ProductType,
        currency: String = "RUB"
    ) -> ProductData {
        
        .init(
            id: id,
            productType: productType,
            // any - i.e., not important:
            number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil,
            currency: "RUB",
            // any - i.e., not important:
            mainField: "", additionalField: nil, customName: nil, productName: "", openDate: nil, ownerId: 1, branchId: nil, allowCredit: true, allowDebit: true, extraLargeDesign: anySVGImageData(), largeDesign: anySVGImageData(), mediumDesign: anySVGImageData(), smallDesign: anySVGImageData(), fontDesignColor: anyColorData(), background: [], order: 0, isVisible: true, smallDesignMd5hash: "", smallBackgroundDesignHash: ""
        )
    }
    
    func makeCardProduct(
        id: Int,
        status: ProductData.Status = .active,
        isMain: Bool? = nil
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
            extraLargeDesign: anySVGImageData(), 
            largeDesign: anySVGImageData(), 
            mediumDesign: anySVGImageData(),
            smallDesign: anySVGImageData(),
            fontDesignColor: anyColorData(),
            background: [],
            accountId: nil,
            cardId: 0,
            name: "CARD",
            validThru: Date(),
            status: status,
            expireDate: "01/01/01",
            holderName: "Иванов",
            product: nil,
            branch: "",
            miniStatement: nil,
            paymentSystemName: nil,
            paymentSystemImage: nil,
            loanBaseParam: nil,
            statusPc: nil,
            isMain: isMain,
            externalId: nil,
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "")
    }
    
    func makeAccountProduct(
        id: Int,
        status: ProductData.Status = .active
    ) -> ProductAccountData {
        
        .init(
            id: id, 
            productType: .account,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "RUB",
            mainField: "Account",
            additionalField: nil,
            customName: nil,
            productName: "Account",
            openDate: nil,
            ownerId: 0,
            branchId: 0,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: anySVGImageData(),
            largeDesign: anySVGImageData(),
            mediumDesign: anySVGImageData(),
            smallDesign: anySVGImageData(),
            fontDesignColor: anyColorData(),
            background: [],
            externalId: 0,
            name: "Ivanov",
            dateOpen: .distantPast,
            status: status,
            branchName: nil,
            miniStatement: [],
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "",
            detailedRatesUrl: "",
            detailedConditionUrl: ""
        )
    }
    
    private func anySVGImageData(
        description: String = ""
    ) -> SVGImageData {
        
        .init(description: description)
    }
    
    private func anyColorData(
        description: String = ""
    ) -> ColorData {
        
        .init(description: description)
    }
}

final class TestIDRangeTests: XCTestCase {
    
    func test_card_testIDRange() {
        
        let productType: ProductType = .card
        let count = 55
        
        XCTAssertEqual(productType.testIDRange(for: count), 0..<55)
    }
    
    func test_account_testIDRange() {
        
        let productType: ProductType = .account
        let count = 44
        
        XCTAssertEqual(productType.testIDRange(for: count), 5_000..<5_044)
    }
    
    func test_deposit_testIDRange() {
        
        let productType: ProductType = .deposit
        let count = 33
        
        XCTAssertEqual(productType.testIDRange(for: count), 10_000..<10_033)
    }
    
    func test_loan_testIDRange() {
        
        let productType: ProductType = .loan
        let count = 22
        
        XCTAssertEqual(productType.testIDRange(for: count), 15_000..<15_022)
    }
}

private extension ProductType {
    
    func testIDRange(for number: Int) -> Range<Int> {
        
        return idRangeStart..<(idRangeStart + number)
    }
    
    private var idRangeStart: Int {
        
        switch self {
        case .card:    return         0
        case .account: return     5_000
        case .deposit: return    10_000
        case .loan:    return    15_000
        }
    }
}

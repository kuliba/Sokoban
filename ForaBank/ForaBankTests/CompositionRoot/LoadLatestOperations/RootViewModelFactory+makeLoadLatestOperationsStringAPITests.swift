//
//  RootViewModelFactory+makeLoadLatestOperationsStringAPITests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.09.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_makeLoadLatestOperationsStringAPITests: XCTestCase {
    
    func test_load_shouldCallGetAllLoadedCategoriesOnAll() {
        
        let (sut, getAllLoadedCategoriesSpy, _) = makeSUT()
        
        let load = sut(.all)
        load { _ in }
        
        XCTAssertEqual(getAllLoadedCategoriesSpy.callCount, 1)
    }
    
    func test_load_shouldNotCallGetAllLoadedCategoriesOnEmptyList() {
        
        let (sut, getAllLoadedCategoriesSpy, _) = makeSUT()
        
        let load = sut(.list([]))
        load { _ in }
        
        XCTAssertEqual(getAllLoadedCategoriesSpy.callCount, 0)
    }
    
    func test_load_shouldNotCallGetAllLoadedCategoriesOnListOfOne() {
        
        let (sut, getAllLoadedCategoriesSpy, _) = makeSUT()
        
        let load = sut(.list([makeServiceCategory()]))
        load { _ in }
        
        XCTAssertEqual(getAllLoadedCategoriesSpy.callCount, 0)
    }
    
    func test_load_shouldNotCallGetAllLoadedCategoriesOnListOfTwo() {
        
        let (sut, getAllLoadedCategoriesSpy, _) = makeSUT()
        
        let load = sut(.list([makeServiceCategory(), makeServiceCategory()]))
        load { _ in }
        
        XCTAssertEqual(getAllLoadedCategoriesSpy.callCount, 0)
    }
    
    func test_load_shouldCallGetLatestPaymentsWithLoadedEmpty_withHardcoded() {
        
        let categories = makeCategories([])
        let (sut, getAllLoadedCategoriesSpy, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.all)
        load { _ in }
        getAllLoadedCategoriesSpy.complete(with: categories)
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [["isOutsidePayments", "isPhonePayments"]])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithLoadedOne_withHardcoded() {
        
        let categories = makeCategories([.charity])
        let (sut, getAllLoadedCategoriesSpy, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.all)
        load { _ in }
        getAllLoadedCategoriesSpy.complete(with: categories)
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [["isCharityPayments", "isOutsidePayments", "isPhonePayments"]])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithLoadedTwo_withHardcoded() {
        
        let categories = makeCategories([.charity, .mobile])
        let (sut, getAllLoadedCategoriesSpy, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.all)
        load { _ in }
        getAllLoadedCategoriesSpy.complete(with: categories)
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [["isCharityPayments", "isMobilePayments", "isOutsidePayments", "isPhonePayments"]])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithLoadedEmpty_emptyHardcoded() {
        
        let (sut, getAllLoadedCategoriesSpy, getLatestPaymentsSpy) = makeSUT(
            hardcoded: []
        )
        
        let load = sut(.all)
        load { _ in }
        getAllLoadedCategoriesSpy.complete(with: [])
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [[]])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithLoadedOne_emptyHardcoded() {
        
        let categories = makeCategories([.charity])
        let (sut, getAllLoadedCategoriesSpy, getLatestPaymentsSpy) = makeSUT(
            hardcoded: []
        )
        
        let load = sut(.all)
        load { _ in }
        getAllLoadedCategoriesSpy.complete(with: categories)
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [["isCharityPayments"]])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithLoadedTwo_emptyHardcoded() {
        
        let categories = makeCategories([.charity, .mobile])
        let (sut, getAllLoadedCategoriesSpy, getLatestPaymentsSpy) = makeSUT(
            hardcoded: []
        )
        
        let load = sut(.all)
        load { _ in }
        getAllLoadedCategoriesSpy.complete(with: categories)
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [["isCharityPayments", "isMobilePayments"]])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithEmptyList() {
        
        let categories = makeCategories([])
        let (sut, _, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.list(categories))
        load { _ in }
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [[]])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithListOfOne() {
        
        let categories = makeCategories([.charity])
        let (sut, _, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.list(categories))
        load { _ in }
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [["isCharityPayments"]])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithListOfTwo() {
        
        let categories = makeCategories([.charity, .mobile])
        let (sut, _, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.list(categories))
        load { _ in }
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [["isCharityPayments", "isMobilePayments"]])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = (CategorySet) -> RootViewModelFactory.LoadLatestOperations
    private typealias GetAllLoadedCategoriesSpy = Spy<Void, [ServiceCategory], Never>
    private typealias GetLatestPaymentsSpy = Spy<[String], Result<[Latest], Error>, Never>
    
    private func makeSUT(
        hardcoded: [String]? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getAllLoadedCategoriesSpy: GetAllLoadedCategoriesSpy,
        getLatestPaymentsSpy: GetLatestPaymentsSpy
    ) {
        let getAllLoadedCategoriesSpy = GetAllLoadedCategoriesSpy()
        let getLatestPaymentsSpy = GetLatestPaymentsSpy()
        let sut: SUT
        if let hardcoded {
            sut = RootViewModelFactory.makeLoadLatestOperations(
                getAllLoadedCategories: getAllLoadedCategoriesSpy.process(completion:),
                getLatestPayments: getLatestPaymentsSpy.process(_:completion:),
                hardcoded: hardcoded
            )
        } else {
            sut = RootViewModelFactory.makeLoadLatestOperations(
                getAllLoadedCategories: getAllLoadedCategoriesSpy.process(completion:),
                getLatestPayments: getLatestPaymentsSpy.process(_:completion:)
            )
        }
        
        trackForMemoryLeaks(getAllLoadedCategoriesSpy, file: file, line: line)
        trackForMemoryLeaks(getLatestPaymentsSpy, file: file, line: line)
        
        return (sut, getAllLoadedCategoriesSpy, getLatestPaymentsSpy)
    }
    
    private func makeServiceCategory(
        latestPaymentsCategory: ServiceCategory.LatestPaymentsCategory? = nil,
        md5Hash: String = anyMessage(),
        name: String = anyMessage(),
        ord: Int = 1,
        paymentFlow: ServiceCategory.PaymentFlow = .standard,
        search: Bool = false,
        type: ServiceCategory.CategoryType = .housingAndCommunalService
    ) -> ServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            search: search,
            type: type
        )
    }
    
    private func makeCategories(
        _ categories: [ServiceCategory.LatestPaymentsCategory]
    ) -> [ServiceCategory] {
        
        let count = categories.count
        let categories = categories.map {  makeServiceCategory(latestPaymentsCategory: $0) }
        XCTAssertEqual(categories.count, count)
        
        return categories
    }
    
    private func makeCategoryNames(
        count: Int
    ) -> [String] {
        
        let categories = (0..<count).map { _ in anyMessage() }
        XCTAssertEqual(categories.count, count)
        
        return categories
    }
}

//
//  RootViewModelFactory+makeLoadLatestOperationsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 20.08.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_makeLoadLatestOperationsTests: XCTestCase {
    
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
    
    func test_load_shouldCallGetLatestPaymentsWithDeliveredEmpty() {
        
        let categories = makeCategories(count: 0)
        let (sut, getAllLoadedCategoriesSpy, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.all)
        load { _ in }
        getAllLoadedCategoriesSpy.complete(with: categories)
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [categories])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithDeliveredOne() {
        
        let categories = makeCategories(count: 1)
        let (sut, getAllLoadedCategoriesSpy, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.all)
        load { _ in }
        getAllLoadedCategoriesSpy.complete(with: categories)
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [categories])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithDeliveredTwo() {
        
        let categories = makeCategories(count: 2)
        let (sut, getAllLoadedCategoriesSpy, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.all)
        load { _ in }
        getAllLoadedCategoriesSpy.complete(with: categories)
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [categories])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithEmptyList() {
        
        let categories = makeCategories(count: 0)
        let (sut, _, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.list(categories))
        load { _ in }
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [categories])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithListOfOne() {
        
        let categories = makeCategories(count: 1)
        let (sut, _, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.list(categories))
        load { _ in }
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [categories])
    }
    
    func test_load_shouldCallGetLatestPaymentsWithListOfTwo() {
        
        let categories = makeCategories(count: 2)
        let (sut, _, getLatestPaymentsSpy) = makeSUT()
        
        let load = sut(.list(categories))
        load { _ in }
        
        XCTAssertEqual(getLatestPaymentsSpy.payloads, [categories])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = (CategorySet) -> RootViewModelFactory.LoadLatestOperations
    private typealias GetAllLoadedCategoriesSpy = Spy<Void, [ServiceCategory], Never>
    private typealias GetLatestPaymentsSpy = Spy<[ServiceCategory], Result<[Latest], Error>, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getAllLoadedCategoriesSpy: GetAllLoadedCategoriesSpy,
        getLatestPaymentsSpy: GetLatestPaymentsSpy
    ) {
        let getAllLoadedCategoriesSpy = GetAllLoadedCategoriesSpy()
        let getLatestPaymentsSpy = GetLatestPaymentsSpy()
        let sut = RootViewModelFactory.makeLoadLatestOperations(
            getAllLoadedCategories: getAllLoadedCategoriesSpy.process(completion:),
            getLatestPayments: getLatestPaymentsSpy.process(_:completion:)
        )
        
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
        hasSearch: Bool = false,
        type: ServiceCategory.CategoryType = .housingAndCommunalService
    ) -> ServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory, 
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            hasSearch: hasSearch,
            type: type
        )
    }
    
    private func makeCategories(
        count: Int
    ) -> [ServiceCategory] {
        
        let categories = (0..<count).map { _ in makeServiceCategory() }
        XCTAssertEqual(categories.count, count)
        
        return categories
    }
}

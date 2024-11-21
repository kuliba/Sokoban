//
//  RootViewModelFactory+makePaymentsTransfersPersonalTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 20.08.2024.
//

@testable import ForaBank
import PayHub
import PayHubUI
import XCTest

final class RootViewModelFactory_makePaymentsTransfersPersonalTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, _,_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_init_shouldCallLoadOnLoad() {
        
        let (sut, _,_, spy) = makeSUT()
        
        sut.content.operationPicker.operationBinder?.content.event(.load)
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetTemplatesAndExchangePrefix() {
        
        let sut = makeSUT().sut
        
        let prefix = sut.content.operationPicker.operationBinder?.content.state.elements.prefix(2)
        
        XCTAssertNoDiff(prefix, [.templates, .exchange])
    }
    
    func test_shouldSetCategoryPickerContentStateToLoading() throws {
        
        let state = try XCTUnwrap(makeSUT().sut.content.categoryPicker.sectionBinder?.content.state)
        
        XCTAssertTrue(state.isLoading)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersPersonal
    private typealias LoadLatestSpy = Spy<Void, Result<[Latest], Error>, Never>
    private typealias ContentDomain = CategoryPickerSectionDomain.ContentDomain
    private typealias LoadCategoriesSpy = Spy<Void, [ServiceCategory], Never>
    private typealias MakeQRModelSpy = CallSpy<Void, QRScannerModel>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadCategoriesSpy: LoadCategoriesSpy,
        reloadCategoriesSpy: LoadCategoriesSpy,
        loadLatestSpy: LoadLatestSpy
    ) {
        let loadCategoriesSpy = LoadCategoriesSpy()
        let reloadCategoriesSpy = LoadCategoriesSpy()
        let loadLatestSpy = LoadLatestSpy()
        let factory = RootViewModelFactory(
            model: .mockWithEmptyExcept(),
            httpClient: HTTPClientSpy(),
            logger: LoggerSpy(),
            resolveQR: { _ in .unknown },
            scanner: QRScannerViewModelSpy(),
            schedulers: .immediate
        )
        let sut = factory.makePaymentsTransfersPersonal(
            nanoServices: .init(
                loadCategories: loadCategoriesSpy.process(completion:),
                reloadCategories: reloadCategoriesSpy.process(completion:),
                loadAllLatest: loadLatestSpy.process(completion:),
                loadLatestForCategory: { _,_ in }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadCategoriesSpy, file: file, line: line)
        trackForMemoryLeaks(reloadCategoriesSpy, file: file, line: line)
        trackForMemoryLeaks(loadLatestSpy, file: file, line: line)
        
        return (sut, loadCategoriesSpy, reloadCategoriesSpy, loadLatestSpy)
    }
}

// MARK: - DSL

extension LoadablePickerState {
    
    var elements: [Element] {
        
        items.compactMap {
            
            guard case let .element(identified) = $0
            else { return nil }
            
            return identified.element
        }
    }
}

//
//  RootViewModelFactory+makePaymentsTransfersBinderTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 20.08.2024.
//

@testable import ForaBank
import PayHub
import XCTest

final class RootViewModelFactory_makePaymentsTransfersBinderTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, _, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }

    func test_init_shouldCallLoadOnLoad() {
        
        let (sut, _, spy) = makeSUT()
        
        sut.content.operationPicker.content.event(.load)
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(sut)
    }

    func test_shouldSetTemplatesAndExchangePrefix() {
        
        let sut = makeSUT().sut
        
        let prefix = sut.content.operationPicker.content.state.elements.prefix(2)
        
        XCTAssertNoDiff(prefix, [.templates, .exchange])
    }

    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersBinder
    private typealias LoadLatestSpy = Spy<Void, [Latest], Never>
    private typealias LoadCategoriesSpy = Spy<Void, [CategoryPickerSectionItem], Never>

    private func makeSUT(
        categoryPickerPlaceholderCount: Int = 6,
        operationPickerPlaceholderCount: Int = 4,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadCategoriesSpy: LoadCategoriesSpy,
        loadLatestSpy: LoadLatestSpy
    ) {
        let loadCategoriesSpy = LoadCategoriesSpy()
        let loadLatestSpy = LoadLatestSpy()
        let sut = RootViewModelFactory.makePaymentsTransfersBinder(
            categoryPickerPlaceholderCount: categoryPickerPlaceholderCount,
            operationPickerPlaceholderCount: operationPickerPlaceholderCount,
            loadCategories: loadCategoriesSpy.process(completion:),
            loadLatestOperations: loadLatestSpy.process(completion:),
            mainScheduler: .immediate,
            backgroundScheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadCategoriesSpy, file: file, line: line)
        trackForMemoryLeaks(loadLatestSpy, file: file, line: line)
        
        return (sut, loadCategoriesSpy, loadLatestSpy)
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

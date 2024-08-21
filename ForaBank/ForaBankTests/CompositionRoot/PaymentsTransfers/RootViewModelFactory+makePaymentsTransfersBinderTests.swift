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
        
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }

    func test_init_shouldCallLoadOnLoad() {
        
        let (sut, spy) = makeSUT()
        
        sut.content.payHubPicker.content.event(.load)
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(sut)
    }

    func test_shouldSetTemplatesAndExchangePrefix() {
        
        let sut = makeSUT().sut
        
        let prefix = sut.content.payHubPicker.content.state.elements.prefix(2)
        
        XCTAssertNoDiff(prefix, [.templates, .exchange])
    }

    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersBinder
    private typealias LoadSpy = Spy<Void, [Latest], Never>

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LoadSpy
    ) {
        let spy = LoadSpy()
        let sut = RootViewModelFactory.makePaymentsTransfersBinder(
            loadLatestOperations: spy.process(completion:),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
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

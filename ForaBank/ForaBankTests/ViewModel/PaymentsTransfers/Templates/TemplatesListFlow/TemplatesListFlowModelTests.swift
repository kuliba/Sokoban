//
//  TemplatesListFlowModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import CombineSchedulers
@testable import ForaBank
import XCTest

final class TemplatesListFlowModelTests: XCTestCase {
    
    func test_init_shouldSetStatusToNil() {
        
        let (sut, _, statusSpy) = makeSUT()
        
        XCTAssertNoDiff(statusSpy.values, [nil])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldChangeStatusOnContentEmittingProductID() {
        
        let productID = makeProductID()
        let (sut, content, statusSpy) = makeSUT()
        
        content.subject.send(productID)
        
        XCTAssertNoDiff(statusSpy.values, [
            .none,
            .outside(.productID(productID))
        ])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TemplatesListFlowModel<Content>
    private typealias ProductID = ProductData.ID
    private typealias StatusSpy = ValueSpy<SUT.State.Status?>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        content: Content,
        statusSpy: StatusSpy
    ) {
        let content = Content()
        let sut = SUT(
            initialState: .init(content: content),
            scheduler: .immediate
        )
        let statusSpy = StatusSpy(sut.$state.map(\.status))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(content, file: file, line: line)
        trackForMemoryLeaks(statusSpy, file: file, line: line)
        
        return (sut, content, statusSpy)
    }
    
    private func makeProductID(
    ) -> ProductID {
        
        return .random(in: 1...100)
    }
    
    private final class Content: ProductIDEmitter {
        
        let subject = PassthroughSubject<ProductID, Never>()
        
        var productIDPublisher: AnyPublisher<ProductID, Never> {
            
            subject.eraseToAnyPublisher()
        }
    }
}

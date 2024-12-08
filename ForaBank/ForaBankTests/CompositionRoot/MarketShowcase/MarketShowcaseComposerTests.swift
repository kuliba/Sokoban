//
//  MarketShowcaseComposerTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 01.10.2024.
//

@testable import Vortex
import XCTest

final class MarketShowcaseComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }

    func test_init_shouldCallLoadOnLoad() {
        
        let (sut, spy) = makeSUT()
        
        sut.compose().content.event(.load)
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MarketShowcaseComposer
    private typealias LoadLandingSpy = Spy<String, Result<MarketShowcaseDomain.Landing, MarketShowcaseDomain.ContentError>, Never>

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadLandingSpy: LoadLandingSpy
    ) {
        let loadLandingSpy = LoadLandingSpy()
        let sut = SUT(
            nanoServices: .init(
                loadLanding: loadLandingSpy.process(_:completion:),
                orderCard: {_ in },
                orderSticker: {_ in }),
            scheduler: .immediate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadLandingSpy, file: file, line: line)
        
        return (sut, loadLandingSpy)
    }
}

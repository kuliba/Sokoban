//
//  QRBinderGetNavigationComposerTests.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHubUI
import XCTest

final class _QRBinderGetNavigationComposerTests: QRBinderTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.makeGetOutsideNavigation.callCount, 0)
        XCTAssertEqual(spies.makeGetQRResultNavigation.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - getOutsideNavigation
    
    func test_getNavigation_shouldCallMakeGetOutsideNavigationWithChatOnOutsideChat() {
        
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(select: .outside(.chat))
        
        XCTAssertNoDiff(spies.makeGetOutsideNavigation.payloads.map(\.0), [.chat])
    }
    
    func test_getNavigation_shouldDeliverOutsideOnOutside() {
        
        let (sut, spies) = makeSUT()
        
        expect(
            sut,
            with: .outside(.chat),
            toDeliver: .outside(.chat)
        ) {
            spies.makeGetOutsideNavigation.complete(with: .outside(.chat))
        }
    }
    
    // MARK: - getQRResultNavigation
    
    func test_getNavigation_shouldCallMakeGetQRResultNavigationOnQRResult() {
        
        let qrResult = make_QRResult()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(select: .qrResult(qrResult))
        
        XCTAssertNoDiff(spies.makeGetQRResultNavigation.payloads.map(\.0), [qrResult])
    }
    
    func test_getNavigation_shouldDeliverQRNavigationOnQRResult() {
        
        let qrNavigation = make_QRNavigation()
        let (sut, spies) = makeSUT()
        
        expect(
            sut,
            with: .qrResult(make_QRResult()),
            toDeliver: .qrNavigation(qrNavigation)
        ) {
            spies.makeGetQRResultNavigation.complete(with: .qrNavigation(qrNavigation))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = _NavigationComposer
    private typealias MakeGetOutsideNavigation = Spy<(SUT.Select.Outside, SUT.Notify), SUT.Navigation>
    private typealias MakeGetQRResultNavigation = Spy<(_QRResult, SUT.Notify), SUT.Navigation>
    
    private struct Spies {
        
        let makeGetOutsideNavigation: MakeGetOutsideNavigation
        let makeGetQRResultNavigation: MakeGetQRResultNavigation
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let spies = Spies(
            makeGetOutsideNavigation: .init(),
            makeGetQRResultNavigation: .init()
        )
        let sut = SUT(
            getOutsideNavigation: spies.makeGetOutsideNavigation.process,
            getQRResultNavigation: spies.makeGetQRResultNavigation.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spies.makeGetOutsideNavigation, file: file, line: line)
        trackForMemoryLeaks(spies.makeGetQRResultNavigation, file: file, line: line)
        
        return (sut, spies)
    }
    
    private func expect(
        _ sut: SUT,
        with select: SUT.Select,
        toDeliver expectedNavigation: SUT.Navigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(select: select, notify: { _ in }) {
            
            XCTAssertNoDiff($0, expectedNavigation, "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}

// MARK: - DSL

private extension _QRBinderGetNavigationComposer {
    
    func getNavigation(
        select: Select
    ) {
        self.getNavigation(select: select, notify: { _ in }, completion: { _ in })
    }
}

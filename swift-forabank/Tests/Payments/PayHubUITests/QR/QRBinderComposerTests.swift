//
//  QRBinderComposerTests.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import PayHubUI
import XCTest

final class QRBinderComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.bindSpy.callCount, 0)
        XCTAssertEqual(spies.getNavigationSpy.callCount, 0)
        XCTAssertEqual(spies.makeQRSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_compose_shouldCallBindAndMakeQR() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose()
        
        XCTAssertEqual(spies.bindSpy.callCount, 1)
        XCTAssertEqual(spies.makeQRSpy.callCount, 1)
    }
    
    func test_composed_shouldCallGetNavigationOnSelectWithQRResult() {
        
        let qrResult = makeQRResult()
        let (sut, spies) = makeSUT()
        let composed = sut.compose()
        
        composed.flow.event(.select(qrResult))
        
        XCTAssertNoDiff(spies.getNavigationSpy.payloads.map(\.0), [qrResult])
    }
    
    func test_composed_shouldCallGetNavigationOnSelectWithNotify() {
        
        let qrResult = makeQRResult()
        let (sut, spies) = makeSUT()
        let composed = sut.compose()
        XCTAssertNil(composed.flow.state.navigation)
        
        composed.flow.event(.select(qrResult))
        spies.getNavigationSpy.complete(with: makeNavigation())
        XCTAssertNotNil(composed.flow.state.navigation)
        
        spies.getNavigationSpy.payloads.first?.1(.dismiss)
        XCTAssertNil(composed.flow.state.navigation)
    }
    
    func test_composed_shouldDeliverNavigationOnSelect() {
        
        let navigation = makeNavigation()
        let (sut, spies) = makeSUT()
        let composed = sut.compose()
        XCTAssertNil(composed.flow.state.navigation)
        
        composed.flow.event(.select(makeQRResult()))
        spies.getNavigationSpy.complete(with: navigation)
        XCTAssertNoDiff(composed.flow.state.navigation, navigation)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRBinderComposer<Navigation, QRModel, QRResult>
    private typealias Domain = SUT.Domain
    private typealias BindSpy = CallSpy<(Domain.Content, Domain.Flow), Set<AnyCancellable>>
    private typealias GetNavigationSpy = Spy<(Domain.Select, Domain.Notify), Navigation>
    private typealias MakeQRSpy = CallSpy<Void, QRModel>
    
    private struct Spies {
        
        let bindSpy: BindSpy
        let getNavigationSpy: GetNavigationSpy
        let makeQRSpy: MakeQRSpy
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let spies = Spies(
            bindSpy: .init(stubs: [[]]),
            getNavigationSpy: .init(),
            makeQRSpy: .init(stubs: [.init()])
        )
        let sut = SUT(
            microServices: .init(
                bind: spies.bindSpy.call,
                getNavigation: spies.getNavigationSpy.process,
                makeQR: spies.makeQRSpy.call
            ),
            mainScheduler: .immediate,
            interactiveScheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spies)
    }
    
    private struct Navigation: Equatable {
        
        let value: String
    }
    
    private func makeNavigation(
        _ value: String = anyMessage()
    ) -> Navigation {
        
        return .init(value: value)
    }
    
    private final class QRModel {}
    
    private struct QRResult: Equatable {
        
        let value: String
    }
    
    private func makeQRResult(
        _ value: String = anyMessage()
    ) -> QRResult {
        
        return .init(value: value)
    }
    
    private enum EquatableSelect: Equatable {
        
        case qrResult(QRResult)
    }
}

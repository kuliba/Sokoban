//
//  QRDestinationComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.10.2024.
//

final class QRDestinationComposer {
    
    private let makeC2BSubscribe: MakeC2BSubscribe
    
    init(
        makeC2BSubscribe: @escaping MakeC2BSubscribe
    ) {
        self.makeC2BSubscribe = makeC2BSubscribe
    }
    
    typealias MakeC2BSubscribe = (URL, @escaping (ClosePaymentsViewModelWrapper) -> Void) -> Void
}

extension QRDestinationComposer {
    
    func compose(
        result: QRModelResult,
        notify: @escaping Notify,
        completion: @escaping QRDestinationCompletion
    ) {
        switch result {
        case let .c2bSubscribeURL(url):
            makeC2BSubscribe(url) {
                
                completion(.c2bSubscribe(.init(
                    model: $0,
                    cancellable: $0.$isClosed.sink { if $0 { notify(.dismiss) }}
                )))
            }
            
        default:
            fatalError()
        }
    }
    
    enum NotifyEvent: Equatable {
        
        case dismiss
    }
    
    enum QRDestination {
        
        case c2bSubscribe(Node<ClosePaymentsViewModelWrapper>)
    }
    
    
    typealias Notify = (NotifyEvent) -> Void
    typealias QRDestinationCompletion = (QRDestination) -> Void
}

import CombineSchedulers
@testable import ForaBank
import XCTest

final class QRDestinationComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, makeC2BSubscribe) = makeSUT()
        
        XCTAssertEqual(makeC2BSubscribe.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - c2bSubscribe
    
    func test_shouldCallMakeC2BSubscribeWithURL() {
        
        let url = anyURL()
        let (sut, makeC2BSubscribe) = makeSUT()
        
        sut.compose(result: .c2bSubscribeURL(url), notify: { _ in }) { _ in }
        
        XCTAssertNoDiff(makeC2BSubscribe.payloads, [url])
    }
    
    func test_shouldDeliverC2BSubscribeOnC2BSubscribeURL() {
        
        let url = anyURL()
        let (sut, makeC2BSubscribe) = makeSUT()
        
        expect(sut, with: .c2bSubscribeURL(url), toDeliver: .c2bSubscribe, on: {
            
            makeC2BSubscribe.complete(with: makeC2BSubscribeResult())
        })
    }
    
    func test_shouldDeliverDismissEventOnC2BSubscribeClose() {
        
        let url = anyURL()
        let (sut, makeC2BSubscribe) = makeSUT()
        var events = [SUT.NotifyEvent]()
        let exp = expectation(description: "wait for completion")
        
        sut.compose(
            result: .c2bSubscribeURL(url),
            notify: { events.append($0) }
        ) {
            $0.c2bSubscribeModel?.closeAction()
            exp.fulfill()
        }
        
        makeC2BSubscribe.complete(with: makeC2BSubscribeResult())
        
        wait(for: [exp], timeout: 1)
        XCTAssertNoDiff(events, [.dismiss])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRDestinationComposer
    private typealias MakeC2BSubscribeSpy = Spy<URL, ClosePaymentsViewModelWrapper, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeC2BSubscribe: MakeC2BSubscribeSpy
    ) {
        let makeC2BSubscribe = MakeC2BSubscribeSpy()
        let sut = SUT(
            makeC2BSubscribe: makeC2BSubscribe.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeC2BSubscribe, file: file, line: line)
        
        return (sut, makeC2BSubscribe)
    }
    
    private func makeC2BSubscribeModel(
        model: Model = .mockWithEmptyExcept(),
        category: Payments.Category = .fast,
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate
    ) -> ClosePaymentsViewModelWrapper {
        
        return .init(model: model, category: category, scheduler: scheduler)
    }
    
    private func makeC2BSubscribeResult(
        model: Model = .mockWithEmptyExcept(),
        category: Payments.Category = .fast,
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate
    ) -> Result<ClosePaymentsViewModelWrapper, Never> {
        
        return .success(makeC2BSubscribeModel(
            model: model,
            category: category,
            scheduler: scheduler
        ))
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with payload: QRModelResult,
        toDeliver expectedResult: EquatableQRDestination,
        notify: @escaping SUT.Notify = { _ in },
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.compose(result: payload, notify: notify) {
            
            XCTAssertNoDiff($0.equatable, expectedResult, "Expected \(expectedResult), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}

private enum EquatableQRDestination: Equatable {
    
    case c2bSubscribe
}

private extension QRDestinationComposer.QRDestination {
    
    var c2bSubscribe: ClosePaymentsViewModelWrapper? {
        
        guard case let .c2bSubscribe(c2bSubscribe) = self
        else { return nil }
        
        return c2bSubscribe.model
    }
    
    var c2bSubscribeModel: PaymentsViewModel? {
        
        return c2bSubscribe?.paymentsViewModel
    }
    
    var equatable: EquatableQRDestination {
        
        switch self {
        case .c2bSubscribe: return .c2bSubscribe
        }
    }
}

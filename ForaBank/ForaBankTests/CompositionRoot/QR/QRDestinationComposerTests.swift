//
//  QRDestinationComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.10.2024.
//

import Combine

final class QRDestinationComposer {
    
    private let makeC2BSubscribe: MakeC2BSubscribe
    private let makeC2B: MakeC2B
    
    init(
        makeC2BSubscribe: @escaping MakeC2BSubscribe,
        makeC2B: @escaping MakeC2B
    ) {
        self.makeC2BSubscribe = makeC2BSubscribe
        self.makeC2B = makeC2B
    }
    
    typealias MakePaymentsWrapper = (URL, @escaping (ClosePaymentsViewModelWrapper) -> Void) -> Void
    typealias MakeC2BSubscribe = MakePaymentsWrapper
    typealias MakeC2B = MakePaymentsWrapper
}

extension QRDestinationComposer {
    
    func compose(
        result: QRModelResult,
        notify: @escaping Notify,
        completion: @escaping QRDestinationCompletion
    ) {
        switch result {
        case let .c2bSubscribeURL(url):
            makeC2BSubscribe(url) { [weak self] in
                
                guard let self else { return }
                
                completion(.c2bSubscribe(.init(
                    model: $0,
                    cancellables: self.bindC2BSubscribe($0, with: notify)
                )))
            }
            
        case let .c2bURL(url):
            makeC2B(url) { [weak self] in
                
                guard let self else { return }
                
                completion(.c2b(.init(
                    model: $0,
                    cancellables: self.bindC2B($0, with: notify)
                )))
            }
            
        default:
            fatalError()
        }
    }
    
    enum NotifyEvent: Equatable {
        
        case contactAbroad(Payments.Operation.Source)
        case dismiss
        case scanQR
    }
    
    enum QRDestination {
        
        case c2bSubscribe(Node<ClosePaymentsViewModelWrapper>)
        case c2b(Node<ClosePaymentsViewModelWrapper>)
    }
    
    typealias Notify = (NotifyEvent) -> Void
    typealias QRDestinationCompletion = (QRDestination) -> Void
}

private extension QRDestinationComposer {
    
    func bindC2B(
        _ wrapper: ClosePaymentsViewModelWrapper,
        with notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        return bindC2BSubscribe(wrapper, with: notify)
    }
    
    func bindC2BSubscribe(
        _ wrapper: ClosePaymentsViewModelWrapper,
        with notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let close = wrapper.$isClosed
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = wrapper.paymentsViewModel.action
            .compactMap { $0 as? PaymentsViewModelAction.ScanQrCode }
            .sink { _ in notify(.scanQR) }
        
        let contactAbroad = wrapper.paymentsViewModel.action
            .compactMap { $0 as? PaymentsViewModelAction.ContactAbroad }
            .map(\.source)
            .sink { notify(.contactAbroad($0)) }
        
        return [close, scanQR, contactAbroad]
    }
}

import CombineSchedulers
@testable import ForaBank
import XCTest

final class QRDestinationComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, makeC2BSubscribe, _) = makeSUT()
        
        XCTAssertEqual(makeC2BSubscribe.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - c2bSubscribe
    
    func test_shouldCallMakeC2BSubscribeWithURL() {
        
        let url = anyURL()
        let (sut, makeC2BSubscribe, _) = makeSUT()
        
        sut.compose(result: .c2bSubscribeURL(url), notify: { _ in }) { _ in }
        
        XCTAssertNoDiff(makeC2BSubscribe.payloads, [url])
    }
    
    func test_shouldDeliverC2BSubscribeOnC2BSubscribeURL() {
        
        let (sut, makeC2BSubscribe, _) = makeSUT()
        
        expect(sut, with: .c2bSubscribeURL(anyURL()), toDeliver: .c2bSubscribe, on: {
            
            makeC2BSubscribe.complete(with: makeC2BSubscribeResult())
        })
    }
    
    func test_shouldDeliverDismissEventOnC2BSubscribeClose() {
        
        let (sut, makeC2BSubscribe, _) = makeSUT()
        
        expect(
            sut,
            result: .c2bSubscribeURL(anyURL()),
            delivers: .dismiss,
            for: { $0.c2bSubscribeModel?.closeAction() },
            on: { makeC2BSubscribe.complete(with: makeC2BSubscribeResult()) }
        )
    }
    
    func test_shouldDeliverScanQREventOnC2BSubscribeScanQRCode() {
        
        let (sut, makeC2BSubscribe, _) = makeSUT()
        
        expect(
            sut,
            result: .c2bSubscribeURL(anyURL()),
            delivers: .scanQR,
            for: { $0.c2bSubscribeScanQR() },
            on: { makeC2BSubscribe.complete(with: makeC2BSubscribeResult()) }
        )
    }
    
    func test_shouldDeliverContactAbroadEventOnC2BSubscribeContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, makeC2BSubscribe, _) = makeSUT()
        
        expect(
            sut,
            result: .c2bSubscribeURL(anyURL()),
            delivers: .contactAbroad(source),
            for: { $0.c2bSubscribeContactAbroad(source: source) },
            on: { makeC2BSubscribe.complete(with: makeC2BSubscribeResult()) }
        )
    }
    
    // MARK: - c2b
    
    func test_shouldCallMakeC2BWithURL() {
        
        let url = anyURL()
        let (sut, _, makeC2B) = makeSUT()
        
        sut.compose(result: .c2bURL(url), notify: { _ in }) { _ in }
        
        XCTAssertNoDiff(makeC2B.payloads, [url])
    }
    
    func test_shouldDeliverC2BOnC2BURL() {
        
        let (sut, _, makeC2B) = makeSUT()
        
        expect(sut, with: .c2bURL(anyURL()), toDeliver: .c2b, on: {
            
            makeC2B.complete(with: makeC2BResult())
        })
    }
    
    func test_shouldDeliverDismissEventOnC2BClose() {
        
        let (sut, _, makeC2B) = makeSUT()
        
        expect(
            sut,
            result: .c2bURL(anyURL()),
            delivers: .dismiss,
            for: { $0.c2bModel?.closeAction() },
            on: { makeC2B.complete(with: makeC2BResult()) }
        )
    }
    
    func test_shouldDeliverScanQREventOnC2BScanQRCode() {
        
        let (sut, _, makeC2B) = makeSUT()
        
        expect(
            sut,
            result: .c2bURL(anyURL()),
            delivers: .scanQR,
            for: { $0.c2bScanQR() },
            on: { makeC2B.complete(with: makeC2BResult()) }
        )
    }
    
    func test_shouldDeliverContactAbroadEventOnC2BContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, _, makeC2B) = makeSUT()
        
        expect(
            sut,
            result: .c2bURL(anyURL()),
            delivers: .contactAbroad(source),
            for: { $0.c2bContactAbroad(source: source) },
            on: { makeC2B.complete(with: makeC2BResult()) }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRDestinationComposer
    private typealias MakeWrapperSpy = Spy<URL, ClosePaymentsViewModelWrapper, Never>
    private typealias MakeC2BSubscribeSpy = MakeWrapperSpy
    private typealias MakeC2BSpy = MakeWrapperSpy
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeC2BSubscribe: MakeC2BSubscribeSpy,
        makeC2B: MakeC2BSpy
    ) {
        let makeC2BSubscribe = MakeC2BSubscribeSpy()
        let makeC2B = MakeC2BSpy()
        let sut = SUT(
            makeC2BSubscribe: makeC2BSubscribe.process(_:completion:),
            makeC2B: makeC2B.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeC2BSubscribe, file: file, line: line)
        trackForMemoryLeaks(makeC2B, file: file, line: line)
        
        return (sut, makeC2BSubscribe, makeC2B)
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
    
    private func makeC2BResult(
        model: Model = .mockWithEmptyExcept(),
        category: Payments.Category = .fast,
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate
    ) -> Result<ClosePaymentsViewModelWrapper, Never> {
        
        return makeC2BSubscribeResult(
            model: model,
            category: category,
            scheduler: scheduler
        )
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
    
    private func expect(
        _ sut: SUT,
        result: QRModelResult,
        delivers expectedEvent: SUT.NotifyEvent,
        for destinationAction: @escaping (SUT.QRDestination) -> Void,
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedEvent: SUT.NotifyEvent?
        let exp = expectation(description: "wait for completion")
        
        sut.compose(
            result: result,
            notify: { receivedEvent = $0 }
        ) {
            destinationAction($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedEvent, expectedEvent, "Expected \(expectedEvent), but got \(String(describing: receivedEvent)) instead.", file: file, line: line)
    }
}
private extension QRDestinationComposer.QRDestination {
    
    // MARK: - c2bSubscribe
    
    var c2bSubscribe: ClosePaymentsViewModelWrapper? {
        
        guard case let .c2bSubscribe(c2bSubscribe) = self
        else { return nil }
        
        return c2bSubscribe.model
    }
    
    var c2bSubscribeModel: PaymentsViewModel? {
        
        return c2bSubscribe?.paymentsViewModel
    }
    
    func c2bSubscribeScanQR() {
        
        c2bSubscribeModel?.action.send(PaymentsViewModelAction.ScanQrCode())
    }
    
    func c2bSubscribeContactAbroad(source: Payments.Operation.Source) {
        
        let action = PaymentsViewModelAction.ContactAbroad(source: source)
        c2bSubscribeModel?.action.send(action)
    }
    
    // MARK: - c2b
    
    var c2b: ClosePaymentsViewModelWrapper? {
        
        guard case let .c2b(c2b) = self
        else { return nil }
        
        return c2b.model
    }
    
    var c2bModel: PaymentsViewModel? {
        
        return c2b?.paymentsViewModel
    }
    
    func c2bScanQR() {
        
        c2bModel?.action.send(PaymentsViewModelAction.ScanQrCode())
    }
    
    func c2bContactAbroad(source: Payments.Operation.Source) {
        
        let action = PaymentsViewModelAction.ContactAbroad(source: source)
        c2bModel?.action.send(action)
    }
    
    var equatable: EquatableQRDestination {
        
        switch self {
        case .c2bSubscribe: return .c2bSubscribe
        case .c2b: return .c2b
        }
    }
}

private enum EquatableQRDestination: Equatable {
    
    case c2bSubscribe
    case c2b
}


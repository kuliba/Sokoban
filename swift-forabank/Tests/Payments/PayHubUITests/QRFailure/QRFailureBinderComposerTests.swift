//
//  QRFailureBinderComposerTests.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

import CombineSchedulers
import PayHubUI
import XCTest

final class QRFailureBinderComposerTests: QRFailureTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies, _) = makeSUT()
        
        XCTAssertEqual(spies.makeCategoryPicker.callCount, 0)
        XCTAssertEqual(spies.makeDetailPayment.callCount, 0)
        XCTAssertEqual(spies.makeQRFailure.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - compose
    
    func test_compose_shouldCallMakeQRFailureWithNilOnNil() {
        
        let (sut, spies, _) = makeSUT()
        
        _ = sut.compose(with: nil)
        
        XCTAssertNoDiff(spies.makeQRFailure.payloads, [nil])
    }
    
    func test_compose_shouldCallMakeQRFailureWithQRCodeDetails() {
        
        let qrCode = makeQRCode()
        let (sut, spies, _) = makeSUT()
        
        _ = sut.compose(with: qrCode)
        
        XCTAssertNoDiff(spies.makeQRFailure.payloads, [qrCode])
    }
    
    // MARK: - payWithDetails
    
    func test_composed_payWithDetails_shouldCallMakeDetailPaymentWithQRCode() {
        
        let qrCode = makeQRCode()
        let (sut, spies, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(with: qrCode)
        composed.content.emit(.payWithDetails(qrCode))
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(spies.makeDetailPayment.payloads, [qrCode])
    }
    
    func test_composed_payWithDetails_shouldCallMakeDetailPaymentWithoutQRCodeOnNilQRCode() {
        
        let (sut, spies, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(with: nil)
        composed.content.emit(.payWithDetails(nil))
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(spies.makeDetailPayment.payloads, [nil])
    }
    
    func test_composed_payWithDetails_shouldDeliverDetailPayment() {
        
        let qrCode = makeQRCode()
        let detailPayment = makeDetailPayment()
        let (sut, _, scheduler) = makeSUT(
            delay: .seconds(500),
            detailPayment: detailPayment
        )
        
        let composed = sut.compose(with: qrCode)
        composed.content.emit(.payWithDetails(qrCode))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .detailPayment(.init(detailPayment))
        )
    }
    
    func test_composed_payWithDetails_shouldDeliverDetailPaymentOnNilQRCode() {
        
        let detailPayment = makeDetailPayment()
        let (sut, _, scheduler) = makeSUT(
            delay: .seconds(500),
            detailPayment: detailPayment
        )
        
        let composed = sut.compose(with: nil)
        composed.content.emit(.payWithDetails(nil))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .detailPayment(.init(detailPayment))
        )
    }
    
    func test_composed_payWithDetails_shouldDeliverScanQROnDetailPaymentScanQR() throws {
        
        let (sut, _, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(with: makeQRCode())
        composed.content.emit(.payWithDetails(makeQRCode()))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        try composed.flow.detailPayment.scanQR()
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .scanQR
        )
    }
    
    func test_composed_payWithDetails_shouldDeliverScanQROnDetailPaymentScanQRNilQRCode() throws {
        
        let (sut, _, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(with: nil)
        composed.content.emit(.payWithDetails(nil))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        try composed.flow.detailPayment.scanQR()
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .scanQR
        )
    }
    
    func test_composed_payWithDetails_shouldDismissOnDetailPaymentClose() throws {
        
        let (sut, _, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(with: makeQRCode())
        composed.content.emit(.payWithDetails(makeQRCode()))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        XCTAssertNotNil(composed.flow.state.navigation)
        
        try composed.flow.detailPayment.close()
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNil(composed.flow.state.navigation)
    }
    
    func test_composed_payWithDetails_shouldDismissOnDetailPaymentCloseOnNilQRCode() throws {
        
        let (sut, _, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(with: makeQRCode())
        composed.content.emit(.payWithDetails(nil))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        XCTAssertNotNil(composed.flow.state.navigation)
        
        try composed.flow.detailPayment.close()
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNil(composed.flow.state.navigation)
    }
    
    // MARK: - search
    
    func test_composed_search_shouldCallMakeCategoryPickerWithQRCode() {
        
        let qrCode = makeQRCode()
        let (sut, spies, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(with: qrCode)
        composed.content.emit(.search(qrCode))
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(spies.makeCategoryPicker.payloads, [qrCode])
    }
    
    func test_composed_search_shouldDeliverCategoryPicker() {
        
        let categoryPicker = makeCategoryPicker()
        let (sut, _, scheduler) = makeSUT(
            delay: .seconds(500),
            categoryPicker: categoryPicker
        )
        
        let composed = sut.compose(with: makeQRCode())
        composed.content.emit(.search(makeQRCode()))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .categories(.init(categoryPicker))
        )
    }
    
    func test_composed_search_shouldDeliverScanQROnCategoryPickerScanQR() throws {
        
        let (sut, _, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(with: makeQRCode())
        composed.content.emit(.search(makeQRCode()))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        try composed.flow.categoryPicker.scanQR()
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .scanQR
        )
    }
    
    func test_composed_search_shouldDismissOnCategoryPickerClose() throws {
        
        let (sut, _, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(with: makeQRCode())
        composed.content.emit(.search(makeQRCode()))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        XCTAssertNotNil(composed.flow.state.navigation)
        
        try composed.flow.categoryPicker.close()
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNil(composed.flow.state.navigation)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRFailureBinderComposer<QRCode, QRFailure, CategoryPicker, DetailPayment>
    private typealias MakeQRFailure = CallSpy<QRCode?, QRFailure>
    private typealias MakeCategoryPicker = CallSpy<QRCode, CategoryPicker>
    private typealias MakeDetailPayment = CallSpy<QRCode?, DetailPayment>
    
    private struct Spies {
        
        let makeQRFailure: MakeQRFailure
        let makeCategoryPicker: MakeCategoryPicker
        let makeDetailPayment: MakeDetailPayment
    }
    
    private func makeSUT(
        delay: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(200),
        qrFailure: QRFailure? = nil,
        categoryPicker: CategoryPicker? = nil,
        detailPayment: DetailPayment? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let spies = Spies(
            makeQRFailure: .init(stubs: [qrFailure ?? makeQRFailure()]),
            makeCategoryPicker: .init(stubs: [categoryPicker ?? makeCategoryPicker()]),
            makeDetailPayment: .init(stubs: [detailPayment ?? makeDetailPayment()])
        )
        let scheduler = DispatchQueue.test
        let sut = SUT(
            delay: delay,
            microServices: .init(
                makeCategoryPicker: spies.makeCategoryPicker.call,
                makeDetailPayment: spies.makeDetailPayment.call,
                makeQRFailure: spies.makeQRFailure.call
            ),
            contentFlowWitnesses: .init(
                contentEmitting: { $0.selectPublisher },
                contentReceiving: { $0.receive },
                flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
                flowReceiving: { flow in { flow.event(.select($0)) }}
            ),
            isClosedWitnesses: .init(
                categoryPicker: { $0.isClosedPublisher },
                detailPayment: { $0.isClosedPublisher }
            ),
            scanQRWitnesses: .init(
                categoryPicker: { $0.scanQRPublisher },
                detailPayment: { $0.scanQRPublisher }
            ),
            schedulers: .init(scheduler)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spies.makeQRFailure, file: file, line: line)
        trackForMemoryLeaks(spies.makeCategoryPicker, file: file, line: line)
        trackForMemoryLeaks(spies.makeDetailPayment, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spies, scheduler)
    }
}

private extension Schedulers {
    
    init(_ testScheduler: TestSchedulerOf<DispatchQueue>) {
        
        self.init(
            main: testScheduler.eraseToAnyScheduler(),
            interactive: testScheduler.eraseToAnyScheduler(),
            userInitiated: testScheduler.eraseToAnyScheduler(),
            background: testScheduler.eraseToAnyScheduler()
        )
    }
}

// MARK: - DSL

extension QRFailureTests.Domain.Flow {
    
    var detailPayment: QRFailureTests.DetailPayment {
        
        get throws {
            
            guard case let .detailPayment(node) = state.navigation
            else { throw NSError(domain: "Expected Detail Payment", code: -1) }
            
            return node.model
        }
    }
    
    var categoryPicker: QRFailureTests.CategoryPicker {
        
        get throws {
            
            guard case let .categoryPicker(node) = state.navigation
            else { throw NSError(domain: "Expected CategoryPicker", code: -1) }
            
            return node.model
        }
    }
}

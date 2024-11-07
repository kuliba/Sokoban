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
        
        XCTAssertEqual(spies.makeCategories.callCount, 0)
        XCTAssertEqual(spies.makeDetailPayment.callCount, 0)
        XCTAssertEqual(spies.makeQRFailure.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - compose
    
    func test_compose_shouldCallMakeQRFailureWithQRCode() {
        
        let qrCode = makeQRCode()
        let (sut, spies, _) = makeSUT()
        
        _ = sut.compose(qrCode: qrCode)
        
        XCTAssertNoDiff(spies.makeQRFailure.payloads, [qrCode])
    }
    
    // MARK: - payWithDetails
    
    func test_composed_payWithDetails_shouldCallMakeDetailPaymentWithQRCode() {
        
        let qrCode = makeQRCode()
        let (sut, spies, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(qrCode: qrCode)
        composed.content.emit(.payWithDetails(qrCode))
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(spies.makeDetailPayment.payloads, [qrCode])
    }
    
    func test_composed_payWithDetails_shouldDeliverDetailPayment() {
        
        let qrCode = makeQRCode()
        let detailPayment = makeDetailPayment()
        let (sut, _, scheduler) = makeSUT(
            delay: .seconds(500),
            detailPayment: detailPayment
        )
        
        let composed = sut.compose(qrCode: qrCode)
        composed.content.emit(.payWithDetails(qrCode))
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
        
        let composed = sut.compose(qrCode: makeQRCode())
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
    
    // MARK: - search
    
    func test_composed_search_shouldCallMakeCategoriesWithQRCode() {
        
        let qrCode = makeQRCode()
        let (sut, spies, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose(qrCode: qrCode)
        composed.content.emit(.search(qrCode))
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(spies.makeCategories.payloads, [qrCode])
    }
    
    func test_composed_search_shouldDeliverCategories() {
        
        let categories = makeCategories()
        let (sut, _, scheduler) = makeSUT(
            delay: .seconds(500),
            categories: categories
        )
        
        let composed = sut.compose(qrCode: makeQRCode())
        composed.content.emit(.search(makeQRCode()))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .categories(.init(categories))
        )
    }
    
    func test_composed_search_shouldDeliverScanQROnCategoriesScanQR() throws {
        
        let categories = makeCategories()
        let (sut, _, scheduler) = makeSUT(
            delay: .seconds(500),
            categories: categories
        )
        
        let composed = sut.compose(qrCode: makeQRCode())
        composed.content.emit(.search(makeQRCode()))
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        try composed.flow.categories.scanQR()
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .scanQR
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRFailureBinderComposer<QRCode, QRFailure, Categories, DetailPayment>
    private typealias MakeQRFailure = CallSpy<QRCode, QRFailure>
    private typealias MakeCategories = CallSpy<QRCode, Categories>
    private typealias MakeDetailPayment = CallSpy<QRCode, DetailPayment>
    
    private struct Spies {
        
        let makeQRFailure: MakeQRFailure
        let makeCategories: MakeCategories
        let makeDetailPayment: MakeDetailPayment
    }
    
    private func makeSUT(
        delay: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(200),
        qrFailure: QRFailure? = nil,
        categories: Categories? = nil,
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
            makeCategories: .init(stubs: [categories ?? makeCategories()]),
            makeDetailPayment: .init(stubs: [detailPayment ?? makeDetailPayment()])
        )
        let scheduler = DispatchQueue.test
        let sut = SUT(
            delay: delay,
            microServices: .init(
                makeCategories: spies.makeCategories.call,
                makeDetailPayment: spies.makeDetailPayment.call,
                makeQRFailure: spies.makeQRFailure.call
            ),
            scanQRWitnesses: .init(
                categories: { $0.scanQRPublisher },
                detailPayment: { $0.scanQRPublisher }
            ),
            witnesses: .init(
                contentEmitting: { $0.selectPublisher },
                contentReceiving: { $0.receive },
                flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
                flowReceiving: { flow in { flow.event(.select($0)) }}
            ),
            scheduler: scheduler.eraseToAnyScheduler(),
            interactiveScheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spies.makeQRFailure, file: file, line: line)
        trackForMemoryLeaks(spies.makeCategories, file: file, line: line)
        trackForMemoryLeaks(spies.makeDetailPayment, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spies, scheduler)
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
    
    var categories: QRFailureTests.Categories {
        
        get throws {
            
            guard case let .categories(node) = state.navigation
            else { throw NSError(domain: "Expected Categories", code: -1) }
            
            return node.model
        }
    }
}

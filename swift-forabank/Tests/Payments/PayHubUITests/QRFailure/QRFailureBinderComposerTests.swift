//
//  QRFailureBinderComposerTests.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub

struct QRFailureBinderComposerMicroServices<QRFailure, Categories, DetailPayment> {
    
    let makeQRFailure: MakeQRFailure
    let makeCategories: MakeCategories
    let makeDetailPayment: MakeDetailPayment
}

extension QRFailureBinderComposerMicroServices {
    
    typealias MakeQRFailure = () -> QRFailure
    typealias MakeCategories = () -> Categories?
    typealias MakeDetailPayment = () -> DetailPayment
}

final class QRFailureBinderComposer<QRFailure, Categories, DetailPayment> {
    
    private let delay: Delay
    private let microServices: MicroServices
    private let witnesses: Witnesses
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        delay: Delay,
        microServices: MicroServices,
        witnesses: Witnesses,
        scheduler: AnySchedulerOf<DispatchQueue>,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.delay = delay
        self.microServices = microServices
        self.witnesses = witnesses
        self.scheduler = scheduler
        self.interactiveScheduler = interactiveScheduler
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    typealias MicroServices = QRFailureBinderComposerMicroServices<QRFailure, Categories, DetailPayment>
    
    typealias Witnesses = ContentFlowWitnesses<QRFailure, Domain.Flow, Domain.Select, Domain.Navigation>
    typealias Domain = QRFailureDomain<QRFailure, Categories, DetailPayment>
}

extension QRFailureBinderComposer {
    
    func compose() -> Domain.Binder {
        
        let factory = ContentFlowBindingFactory(delay: delay, scheduler: scheduler)
        let composer = Domain.FlowComposer(
            getNavigation: { [weak self] select, notify, completion in
                
                guard let self else { return }
                
                switch select {
                case .payWithDetails:
                    let detailPayment = microServices.makeDetailPayment()
                    completion(.detailPayment(detailPayment))
                    
                case .search:
                    let categories = microServices.makeCategories()
                    completion(.categories(.init {
                        
                        try categories.get(orThrow: MakeCategoriesFailure())
                    }))
                }
            },
            scheduler: scheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return .init(
            content: microServices.makeQRFailure(),
            flow: composer.compose(),
            bind: factory.bind(with: witnesses)
        )
    }
    
    struct MakeCategoriesFailure: Error {}
}

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
    
    // MARK: - payWithDetails
    
    func test_composed_payWithDetails_shouldCallMakeDetailPayment() {
        
        let (sut, spies, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose()
        composed.content.emit(.payWithDetails)
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(spies.makeDetailPayment.payloads.count, 1)
    }
    
    func test_composed_payWithDetails_shouldDeliverDetailPayment() {
        
        let detailPayment = makeDetailPayment()
        let (sut, _, scheduler) = makeSUT(
            delay: .seconds(500),
            detailPayment: detailPayment
        )
        
        let composed = sut.compose()
        composed.content.emit(.payWithDetails)
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .detailPayment(detailPayment)
        )
    }
    
    // MARK: - search
    
    func test_composed_search_shouldCallMakeCategories() {
        
        let (sut, spies, scheduler) = makeSUT(delay: .seconds(500))
        
        let composed = sut.compose()
        composed.content.emit(.search)
        scheduler.advance(by: .seconds(500))
        
        XCTAssertNoDiff(spies.makeCategories.payloads.count, 1)
    }
    
    func test_composed_search_shouldDeliverFailureOnCategoriesFailure() {
        
        let (sut, _, scheduler) = makeSUT(
            delay: .seconds(500),
            categories: .none
        )
        
        let composed = sut.compose()
        composed.content.emit(.search)
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .categories(.failure(.init()))
        )
    }
    
    func test_composed_search_shouldDeliverCategories() {
        
        let categories = makeCategories()
        let (sut, _, scheduler) = makeSUT(
            delay: .seconds(500),
            categories: categories
        )
        
        let composed = sut.compose()
        composed.content.emit(.search)
        scheduler.advance(by: .seconds(500))
        scheduler.advance(to: .init(.now()))
        scheduler.advance(by: .milliseconds(100))
        
        XCTAssertNoDiff(
            composed.flow.state.navigation.map(equatable),
            .categories(.success(categories))
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRFailureBinderComposer<QRFailure, Categories, DetailPayment>
    private typealias MakeQRFailure = CallSpy<Void, QRFailure>
    private typealias MakeCategories = CallSpy<Void, Categories?>
    private typealias MakeDetailPayment = CallSpy<Void, DetailPayment>
    
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
            makeCategories: .init(stubs: [categories]),
            makeDetailPayment: .init(stubs: [detailPayment ?? makeDetailPayment()])
        )
        let scheduler = DispatchQueue.test
        let sut = SUT(
            delay: delay,
            microServices: .init(
                makeQRFailure: spies.makeQRFailure.call,
                makeCategories: spies.makeCategories.call,
                makeDetailPayment: spies.makeDetailPayment.call
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

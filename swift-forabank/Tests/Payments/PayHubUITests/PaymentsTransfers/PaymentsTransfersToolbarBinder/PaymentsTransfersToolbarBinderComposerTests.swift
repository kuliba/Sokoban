//
//  PaymentsTransfersToolbarBinderComposerTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import CombineSchedulers
import Foundation

final class PaymentsTransfersToolbarBinderComposer<Profile, QR> {
    
    private let microServices: MicroServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        microServices: MicroServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.microServices = microServices
        self.scheduler = scheduler
    }
    
    typealias MicroServices = PaymentsTransfersToolbarFlowEffectHandlerMicroServices<Profile, QR>
}

extension PaymentsTransfersToolbarBinderComposer {
    
    func compose(
        selection: PaymentsTransfersToolbarState.Selection? = nil
    ) -> Binder<Content, Flow> {
        
        return .init(
            content: makeContent(selection: selection),
            flow: makeFlow()
        ) { content, flow in
            
            let flowNavigation = flow.$state.map(\.navigation)
            let dismiss = flowNavigation
                .combineLatest(flowNavigation.dropFirst())
                .filter { $0.0 != nil && $0.1 == nil }
                .debounce(for: .milliseconds(100), scheduler: scheduler)
                .sink { _ in content.event(.select(nil)) }
            
            let select = content.$state
                .compactMap(\.selection)
                .sink {
                    
                    switch $0 {
                    case .profile:
                        flow.event(.select(.profile))
                    case .qr:
                        flow.event(.select(.qr))
                    }
                }
            
            return [dismiss, select]
        }
    }
    
    typealias Content = RxViewModel<PaymentsTransfersToolbarState, PaymentsTransfersToolbarEvent, PaymentsTransfersToolbarEffect>
    typealias Flow = RxViewModel<PaymentsTransfersToolbarFlowState<Profile, QR>, PaymentsTransfersToolbarFlowEvent<Profile, QR>, PaymentsTransfersToolbarFlowEffect>
}

// MARK: - Content

private extension PaymentsTransfersToolbarBinderComposer {
    
    func makeContent(
        selection: PaymentsTransfersToolbarState.Selection?
    ) -> Content {
        
        let reducer = PaymentsTransfersToolbarReducer()
        let effectHandler = PaymentsTransfersToolbarEffectHandler(
            microServices: .init()
        )
        
        return .init(
            initialState: .init(selection: selection),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

// MARK: - Flow

private extension PaymentsTransfersToolbarBinderComposer {
    
    func makeFlow() -> Flow {
        
        let reducer = PaymentsTransfersToolbarFlowReducer<Profile, QR>()
        let effectHandler = PaymentsTransfersToolbarFlowEffectHandler(
            microServices: microServices
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

import Combine
import PayHub
import RxViewModel
import XCTest

final class PaymentsTransfersToolbarBinderComposerTests: XCTestCase {
    
    func test_shouldNotChangeFlowNavigationOnContentDeselectEvent() {
        
        let (sut, _,_, scheduler) = makeSUT(selection: .profile)
        let contentSpy = ValueSpy(sut.content.$state.map(\.selection))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [.profile])
        XCTAssertNoDiff(flowSpy.values, [nil])
        
        sut.content.event(.select(nil))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [.profile, nil])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_profile() {
        
        let profile = makeProfile()
        let (sut, makeProfile, _, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selection))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])

        sut.content.event(.select(.profile))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .profile])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])

        makeProfile.complete(with: profile)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .profile])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .profile(profile)])
    }
    
    func test_shouldChangeFlowNavigationOnContentSelectEvent_qr() {
        
        let qr = makeQR()
        let (sut, _, makeQR, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selection))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        XCTAssertNoDiff(contentSpy.values, [nil])
        XCTAssertNoDiff(flowSpy.values, [nil])

        sut.content.event(.select(.qr))
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .qr])
        XCTAssertNoDiff(flowSpy.values, [nil, nil])

        makeQR.complete(with: qr)
        scheduler.advance()
        
        XCTAssertNoDiff(contentSpy.values, [nil, .qr])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .qr(qr)])
    }
    
    func test_shouldResetContentSelectionOnFlowDismissEvent() {
        
        let qr = makeQR()
        let (sut, _, makeQR, scheduler) = makeSUT()
        let contentSpy = ValueSpy(sut.content.$state.map(\.selection))
        let flowSpy = ValueSpy(sut.flow.$state.map(\.navigation))
        
        sut.content.event(.select(.qr))
        scheduler.advance()
        
        makeQR.complete(with: qr)
        scheduler.advance()

        XCTAssertNoDiff(contentSpy.values, [nil, .qr])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .qr(qr)])
        
        sut.flow.event(.dismiss)
        scheduler.advance(by: .milliseconds(100))

        XCTAssertNoDiff(contentSpy.values, [nil, .qr, nil])
        XCTAssertNoDiff(flowSpy.values, [nil, nil, .qr(qr), nil])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = PaymentsTransfersToolbarBinderComposer<Profile, QR>
    private typealias Content = Composer.Content
    private typealias Flow = Composer.Flow
    private typealias SUT = Binder<Content, Flow>
    private typealias MakeProfileSpy = Spy<Void, Profile>
    private typealias MakeQRSpy = Spy<Void, QR>
    
    private func makeSUT(
        selection: PaymentsTransfersToolbarState.Selection? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeProfile: MakeProfileSpy,
        makeQR: MakeQRSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let makeProfile = MakeProfileSpy()
        let makeQR = MakeQRSpy()
        let scheduler = DispatchQueue.test
        let composer = PaymentsTransfersToolbarBinderComposer(
            microServices: .init(
                makeProfile: makeProfile.process(completion:),
                makeQR: makeQR.process(completion:)
            ),
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = composer.compose(selection: selection)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeProfile, file: file, line: line)
        trackForMemoryLeaks(makeQR, file: file, line: line)
        
        return (sut, makeProfile, makeQR, scheduler)
    }
    
    struct Profile: Equatable {
        
        let value: String
    }
    
    func makeProfile(
        _ value: String = anyMessage()
    ) -> Profile {
        
        return .init(value: value)
    }
    
    struct QR: Equatable {
        
        let value: String
    }
    
    func makeQR(
        _ value: String = anyMessage()
    ) -> QR {
        
        return .init(value: value)
    }
}

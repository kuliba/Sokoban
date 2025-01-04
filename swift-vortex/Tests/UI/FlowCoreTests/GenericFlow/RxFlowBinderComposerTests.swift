//
//  RxFlowBinderComposerTests.swift
//  swift-vortex
//
//  Created by Igor Malyarov on 04.01.2025.
//

import CombineSchedulers

final class RxFlowBinderComposer<Select, Navigation> {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.scheduler = scheduler
    }
}

extension RxFlowBinderComposer {
    
    func compose(
        initialState: FlowDomain.State = .init(),
        getNavigation: @escaping FlowDomain.Composer.GetNavigation
    ) -> Binder {

        let composer = FlowComposer(
            getNavigation: getNavigation,
            scheduler: scheduler
        )
        
        return .init(
            content: (),
            flow: composer.compose(initialState: initialState),
            bind: { _,_ in [] }
        )
    }
    
    typealias Content = Void
    typealias Binder = FlowCore.Binder<Content, Flow>
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
}

import FlowCore
import XCTest

final class RxFlowBinderComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getNavigation) = makeSUT()
        
        XCTAssertEqual(getNavigation.callCount, 0)
    }
    
    func test_compose_shouldSetInitialFlowState() {
        
        let initialState = makeFlowState(
            isLoading: true,
            navigation: makeNavigation()
        )
        let (binder, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(binder.flow.state, initialState)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxFlowBinderComposer<Select, Navigation>
    private typealias Binder = SUT.Binder
    private typealias Select = Void
    private typealias GetNavigationSpy = Spy<Select, Navigation>
    private typealias FlowState = SUT.FlowDomain.State
    
    private func makeSUT(
        initialState: FlowState = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        binder: Binder,
        getNavigation: GetNavigationSpy
    ) {
        let getNavigation = GetNavigationSpy()
        let sut = SUT(scheduler: .immediate)
        let binder = sut.compose(
            initialState: initialState,
            getNavigation: { _,_,_ in }
        )
        
        trackForMemoryLeaks(getNavigation, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(binder, file: file, line: line)
        
        return (binder, getNavigation)
    }
    
    private func makeFlowState(
        isLoading: Bool = false,
        navigation: Navigation? = nil
    ) -> FlowState {
        
        return .init(isLoading: isLoading, navigation: navigation)
    }
    
    private struct Navigation: Equatable {
        
        let value: String
    }
    
    private func makeNavigation(
        _ value: String = anyMessage()
    ) -> Navigation {
        
        return .init(value: value)
    }
}

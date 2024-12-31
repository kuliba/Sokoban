//
//  FlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 31.12.2024.
//

import CombineSchedulers
import PayHub
import XCTest

final class FlowIntegrationTests: XCTestCase {
    
    func test_init_shouldSetInitialState() {
        
        let initialState = makeState(isLoading: true)
        let (_, spy) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [initialState])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ParentDomain.Flow
    private typealias State = ParentDomain.FlowDomain.State
    
    private func makeSUT(
        initialState: State = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ValueSpy<State>
    ) {
        let composer = ParentComposer()
        let sut = composer.compose(initialState: initialState)
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeState(
        isLoading: Bool = false,
        navigation: ParentDomain.Navigation? = nil
    ) -> State {
        
        return .init(isLoading: isLoading, navigation: navigation)
    }
}

private enum ParentDomain {
    
    // MARK: - Binder - no Binder
    
    // MARK: - Content - no Content
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {}
    enum Navigation: Equatable {}
}

private final class ParentComposer {
    
    let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        
        self.scheduler = scheduler
    }
}

extension ParentComposer {
    
    func compose(
        initialState: ParentDomain.FlowDomain.State
    ) -> ParentDomain.Flow {
        
        let composer = FlowComposer(
            getNavigation: getNavigation,
            scheduler: scheduler
        )
        
        return composer.compose(initialState: initialState)
    }
    
    func getNavigation(
        select: ParentDomain.Select,
        notify: @escaping ParentDomain.Notify,
        completion: @escaping (ParentDomain.Navigation) -> Void
    ) {
        switch select {
            
        }
    }
}

//
//  PickerFlowComposerTests.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import CombineSchedulers
import PayHubUI
import XCTest

final class PickerFlowComposerTests: XCTestCase {
    
    func test_compose_shouldSetInitialState_empty() {
        
        let (_,_, stateSpy) = makeSUT()
        
        XCTAssertNoDiff(stateSpy.values, [.init()])
    }
    
    func test_compose_shouldSetInitialState() {
        
        let navigation = makeNavigation()
        let (_,_, stateSpy) = makeSUT(
            initialState: .init(
                isLoading: true,
                navigation: navigation
            ))
        
        XCTAssertNoDiff(stateSpy.values, [.init(
            isLoading: true,
            navigation: navigation
        )])
    }
    
    func test_events() {
        
        let navigation = makeNavigation()
        let (sut, makeNavigation, stateSpy) = makeSUT()
        
        sut.event(.select(makeElement()))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(isLoading: true),
        ])
        
        makeNavigation.complete(with: navigation)
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(isLoading: true),
            .init(navigation: navigation),
        ])
        
        sut.event(.dismiss)
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(isLoading: true),
            .init(navigation: navigation),
            .init(),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = PickerFlowComposer<Element, Navigation>
    private typealias SUT = PickerFlow<Element, Navigation>
    private typealias MakeNavigationSpy = Spy<Element, Navigation>
    
    private func makeSUT(
        initialState: Composer.State = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        flow: SUT,
        makeNavigation: MakeNavigationSpy,
        stateSpy: ValueSpy<Composer.State>
    ) {
        let makeNavigation = MakeNavigationSpy()
        let composer = Composer(
            makeNavigation: makeNavigation.process(_:completion:),
            scheduler: .immediate
        )
        let sut = composer.compose(initialState: initialState)
        let stateSpy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeNavigation, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        
        return (sut, makeNavigation, stateSpy)
    }
    
    private struct Element: Equatable {
        
        let value: String
    }
    
    private func makeElement(
        _ value: String = anyMessage()
    ) -> Element {
        
        return .init(value: value)
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

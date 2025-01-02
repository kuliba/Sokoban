//
//  ChildFlowObservationTests.swift
//
//
//  Created by Igor Malyarov on 31.12.2024.
//

import Combine

extension Publisher where Failure == Never {
    
    /// Projects a FlowState into a FlowEvent based on `Navigation` mapping and `isLoading`.
    func project<Projection, Select>(
        _ transform: @escaping (Projection) -> NavigationOutcome<Select>?
    ) -> AnyPublisher<FlowEvent<Select, Never>, Never> where Output == FlowState<Projection> {
        
        map { $0.project(transform) }
            .eraseToAnyPublisher()
    }
}

extension FlowState {
    
    func project<Select>(
        _ transform: @escaping (Navigation) -> NavigationOutcome<Select>?
    ) -> FlowEvent<Select, Never> {
        
        if isLoading {
            return .isLoading(true)
        }
        
        if let navigation = navigation.map(transform) {
            switch navigation {
            case .dismiss:
                return .dismiss
                
            case let .select(select):
                return .select(select)
                
            case .none:
                break
            }
        }
        
        return .isLoading(false)
    }
}

import PayHub
import XCTest

/**
 
 # Explore ChildFlow-to-ParentFlow Communication

 ## Spinner/ProgressView

 **Question**: How can we pass `isLoading` between flows, so that `Parent.Flow` updates its `isLoading` property in response to the `Child.Flow`’s `isLoading`, rather than just reacting to changes in `Child.Flow`’s navigation (current implementation)?

 **General Idea**: The parent flow observes a projection of the child flow’s state, i.e. `Child.FlowState<Child.Navigation>`. This projection has the same `FlowState` shape as `FlowState<Projection>`, where `Projection` is a subset (or potentially all) of `Child.Navigation`.

 By defining a suitable `FlowEvent<Projection>` and wiring the child’s updates to a `Notify` closure in `FlowEffectHandler`, the parent can subscribe to those updates. Whenever the child flow indicates a loading change or any other relevant event, the parent can modify its own `isLoading` state accordingly.

 In other words:
 1. **Child Flow** manages its own `FlowState<Child.Navigation>`, including `isLoading`.
 2. **Projection**: Create a way to map or "project" the child’s `FlowState` into a form the parent understands (e.g., `FlowEvent<Projection>`).
 3. **Parent Flow** observes these events via a `Notify` closure or similar mechanism, then updates its own `FlowState` (including `isLoading`).

 This structure ensures a clear unidirectional data flow: the child notifies changes, and the parent subscribes to them. As a result, the `Parent.Flow` can seamlessly reflect the child’s `isLoading` status without relying exclusively on navigation changes.
 
 */

final class ChildFlowObservationTests: XCTestCase {
    
    func test_init_shouldNotEmitValues() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_shouldDeliverIsLoadingTrue_onIsLoadingTrueNilNavigation() {
        
        let (subject, spy) = makeSUT()
        
        subject.send(makeChildState(true, nil))
        
        XCTAssertNoDiff(spy.values, [.isLoading(true)])
    }
    
    func test_shouldDeliverIsLoadingTrue_onIsLoadingTrueNonNilNavigation() {
        
        let (subject, spy) = makeSUT()
        
        subject.send(makeChildState(true, .outside(.right)))
        
        XCTAssertNoDiff(spy.values, [.isLoading(true)])
    }
    
    func test_shouldDeliverIsLoadingFalse_onIsLoadingFalseNilNavigation() {
        
        let (subject, spy) = makeSUT()
        
        subject.send(makeChildState(false, nil))
        
        XCTAssertNoDiff(spy.values, [.isLoading(false)])
    }
    
    func test_shouldDeliverSelectProjection_onIsLoadingFalseNonNilNavigation() {
        
        let (subject, spy) = makeSUT()
        
        subject.send(makeChildState(false, .outside(.left)))
        
        XCTAssertNoDiff(spy.values, [.select(.out(.left))])
    }
    
    func test_shouldDeliverIsLoadingFalse_onNonProjectedChildState() {
        
        let (subject, spy) = makeSUT()
        
        subject.send(makeChildState(false, .somewhere))
        
        XCTAssertNoDiff(spy.values, [.isLoading(false)])
    }
    
    // MARK: - Helpers
    
    private typealias ChildState = FlowState<ChildNavigation>
    private typealias Subject = PassthroughSubject<ChildState, Never>
    private typealias Event = FlowEvent<ParentNavigation, Never>
    private typealias Spy = ValueSpy<Event>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        subject: Subject,
        spy: Spy
    ) {
        let subject = Subject()
        let spy = Spy(subject.project(mapNavigation))
        
        trackForMemoryLeaks(subject, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (subject, spy)
    }
    
    private func makeChildState(
        _ isLoading: Bool,
        _ navigation: ChildNavigation?
    ) -> ChildState {
        
        return .init(isLoading: isLoading, navigation: navigation)
    }
    
    private func mapNavigation(
        _ navigation: ChildNavigation
    ) -> NavigationOutcome<ParentNavigation>? {
        
        switch navigation {
        case let .outside(outside):
            switch outside {
            case .left: return .select(.out(.left))
            case .right: return .select(.out(.right))
            }
            
        case .somewhere:
            return nil
        }
    }
    
    private enum ChildNavigation: Equatable {
        
        case outside(Outside)
        case somewhere
        
        enum Outside: Equatable {
            
            case left, right
        }
    }
    
    private enum ParentNavigation: Equatable {
        
        case out(Out)
        
        enum Out: Equatable {
            
            case left, right
        }
    }
}

//
//  RootViewBinderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.11.2024.
//

import Combine
@testable import ForaBank
import XCTest

final class RootViewBinderComposerTests: XCTestCase {
    
    func test_shouldCallDismissOnDismissAll() {
        
        var dismissCallCount = 0
        let (sut, dismissAllSubject) = makeSUT(dismiss: { dismissCallCount += 1 })
        let binder = compose(with: sut)
        
        dismissAllSubject.send(.init())
        
        XCTAssertEqual(dismissCallCount, 1)
        XCTAssertNotNil(binder)
    }
    
    func test_shouldCallResetOnDismissAll() {
        
        var resetCallCount = 0
        let (sut, dismissAllSubject) = makeSUT(reset: { resetCallCount += 1})
        let binder = compose(with: sut)
        
        dismissAllSubject.send(.init())
        
        XCTAssertEqual(resetCallCount, 1)
        XCTAssertNotNil(binder)
    }
    
    func test_shouldPreserveBindings() {
        
        var uuids = [UUID]()
        let (uuid1, uuid2) = (UUID(), UUID())
        let subject = PassthroughSubject<UUID, Never>()
        var cancellable: AnyCancellable? = subject.sink { uuids.append($0) }
        let (sut, _) = makeSUT(
            bindings: .init(([cancellable].compactMap { $0 }))
        )
        cancellable = nil
        let binder = compose(with: sut)
        
        subject.send(uuid1)
        subject.send(uuid2)
        
        XCTAssertNoDiff(uuids, [uuid1, uuid2])
        XCTAssertNotNil(binder)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RootViewBinderComposer<RootViewModel>
    private typealias DismissAllSubject = PassthroughSubject<RootViewModelAction.DismissAll, Never>
    
    private func makeSUT(
        bindings: Set<AnyCancellable> = [],
        dismiss: @escaping () -> Void = {},
        reset: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        dismissAllSubject: DismissAllSubject
    ) {
        let dismissAllSubject = DismissAllSubject()
        
        let sut = SUT(
            bindings: bindings,
            dismiss: dismiss,
            getNavigation: { _,_,_ in },
            schedulers: .immediate,
            witnesses: .init(
                contentFlow: .init(
                    contentEmitting: { _ in Empty().eraseToAnyPublisher() },
                    contentReceiving: { _ in {}},
                    flowEmitting: { _ in Empty().eraseToAnyPublisher() },
                    flowReceiving: { _ in { _ in }}
                ),
                dismiss: .init(
                    dismissAll: { _ in dismissAllSubject.eraseToAnyPublisher() },
                    reset: { _ in reset }
                )
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(dismissAllSubject, file: file, line: line)
        
        return (sut, dismissAllSubject)
    }
    
    private func compose(
        with sut: SUT
    ) -> SUT.RootDomain.Binder {
        
        sut.compose(with: makeRootViewModel())
    }
    
    private final class RootViewModel {}
    
    private func makeRootViewModel() -> RootViewModel {
        
        return .init()
    }
}

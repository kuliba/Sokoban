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
    
    func test_compose_shouldSetContent() {
        
        let content = makeRootViewModel()
        let (sut, _) = makeSUT()
        
        let binder = sut.compose(with: content)
        
        XCTAssertTrue(binder.content === content)
    }
    
    func test_flow_shouldSetScanQRNavigationOnContentScanQRSelect() {
        
        let (sut, _) = makeSUT()
        let binder = sut.compose(with: makeRootViewModel())
        XCTAssertNil(binder.flow.state.navigation)
        
        binder.content.emit(.scanQR)
        
        XCTAssertNoDiff(binder.flow.state.navigation, .scanQR)
    }
    
    func test_content_shouldReceiveOnFlowNavigationDismiss() {
        
        let (sut, _) = makeSUT()
        let binder = sut.compose(with: makeRootViewModel())
        binder.content.emit(.scanQR)
        XCTAssertEqual(binder.content.receiveCount, 0)
        
        binder.flow.event(.dismiss)

        XCTAssertEqual(binder.content.receiveCount, 1)
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
            getNavigation: { select, notify, completion in
                
                switch select {
                case .scanQR:
                    completion(.scanQR)
                }
            },
            schedulers: .immediate,
            witnesses: .init(
                contentFlow: .init(
                    contentEmitting: { $0.selectPublisher },
                    contentReceiving: { $0.receive },
                    flowEmitting: { $0.$state.map(\.navigation).eraseToAnyPublisher() },
                    flowReceiving: { flow in { flow.event(.select($0)) }}
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
    
    private final class RootViewModel {
        
        typealias Select = SUT.RootDomain.Select
        
        private let selectSubject = PassthroughSubject<Select, Never>()
        private(set) var receiveCount = 0
        
        var selectPublisher: AnyPublisher<Select, Never> {
            
            selectSubject.eraseToAnyPublisher()
        }
        
        func emit(_ select: Select) {
            
            selectSubject.send(select)
        }
        
        func receive() {
            
            receiveCount += 1
        }
    }
    
    private func makeRootViewModel() -> RootViewModel {
        
        return .init()
    }
}

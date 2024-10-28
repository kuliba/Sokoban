//
//  QRBinderComposerTests.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import PayHub

/// A namespace/
enum QRDomain<QR> {}

extension QRDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = QR
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    enum Select {}
    
    enum Navigation {}
}

struct QRBinderComposerMicroServices<QR> {
    
    let bind: Bind
    let getNavigation: GetNavigation
    let makeQR: MakeQR
}

extension QRBinderComposerMicroServices {
    
    typealias Bind = (Domain.Content, Domain.Flow) -> Set<AnyCancellable>
    
    typealias NavigationCompletion = (Domain.Navigation) -> Void
    typealias GetNavigation = (Domain.Select, @escaping Domain.Notify, @escaping NavigationCompletion) -> Void
    
    typealias MakeQR = () -> QR
    
    typealias Domain = QRDomain<QR>
}

import Combine
import CombineSchedulers
import Foundation

final class QRBinderComposer<QR> {
    
    let microServices: MicroServices
    let mainScheduler: AnySchedulerOf<DispatchQueue>
    let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        microServices: MicroServices,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.microServices = microServices
        self.mainScheduler = mainScheduler
        self.interactiveScheduler = interactiveScheduler
    }
    
    typealias MicroServices = QRBinderComposerMicroServices<QR>
}

extension QRBinderComposer {
    
    func compose() -> Domain.Binder {
        
        let composer = Domain.FlowDomain.Composer(
            microServices: .init(
                getNavigation: microServices.getNavigation
            ),
            scheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return .init(
            content: microServices.makeQR(),
            flow: composer.compose(),
            bind: microServices.bind
        )
    }
    
    typealias Domain = QRDomain<QR>
}

import PayHubUI
import XCTest

final class QRBinderComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.bindSpy.callCount, 0)
        XCTAssertEqual(spies.getNavigationSpy.callCount, 0)
        XCTAssertEqual(spies.makeQRSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_compose_shouldCallBindAndMakeQR() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose()
        
        XCTAssertEqual(spies.bindSpy.callCount, 1)
        XCTAssertEqual(spies.makeQRSpy.callCount, 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRBinderComposer<QRModel>
    private typealias Domain = SUT.Domain
    private typealias BindSpy = CallSpy<(Domain.Content, Domain.Flow), Set<AnyCancellable>>
    private typealias GetNavigationSpy = Spy<(Domain.Select, Domain.Notify), Domain.Navigation>
    private typealias MakeQRSpy = CallSpy<Void, QRModel>
    
    private struct Spies {
        
        let bindSpy: BindSpy
        let getNavigationSpy: GetNavigationSpy
        let makeQRSpy: MakeQRSpy
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let spies = Spies(
            bindSpy: .init(stubs: [[]]),
            getNavigationSpy: .init(),
            makeQRSpy: .init(stubs: [.init()])
        )
        let sut = SUT(
            microServices: .init(
                bind: spies.bindSpy.call,
                getNavigation: spies.getNavigationSpy.process,
                makeQR: spies.makeQRSpy.call
            ),
            mainScheduler: .immediate,
            interactiveScheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spies)
    }
    
    private final class QRModel {}
}

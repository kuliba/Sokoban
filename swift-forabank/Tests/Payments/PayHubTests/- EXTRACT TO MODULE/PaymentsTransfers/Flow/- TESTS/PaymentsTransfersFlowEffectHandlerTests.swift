//
//  PaymentsTransfersFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

enum PaymentsTransfersFlowEvent<Profile, QR> {
    
    case open(Open)
    case profile(Profile)
    case qr(QR)
}

extension PaymentsTransfersFlowEvent {
    
    enum Open {
        
        case profile, qr
    }
}

extension PaymentsTransfersFlowEvent: Equatable where Profile: Equatable, QR: Equatable {}

enum PaymentsTransfersFlowEffect: Equatable {
    
    case profile, qr
}

struct PaymentsTransfersFlowEffectHandlerMicroServices<Profile, QR> {
    
    let makeProfile: MakeProfile
    let makeQR: MakeQR
}

extension PaymentsTransfersFlowEffectHandlerMicroServices {
    
    typealias MakeProfileCompletion = (Profile) -> Void
    typealias MakeProfile = (@escaping MakeProfileCompletion) -> Void
    
    typealias MakeQRCompletion = (QR) -> Void
    typealias MakeQR = (@escaping MakeQRCompletion) -> Void
}

final class PaymentsTransfersFlowEffectHandler<Profile, QR> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = PaymentsTransfersFlowEffectHandlerMicroServices<Profile, QR>
}

extension PaymentsTransfersFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .profile:
            handleProfile(dispatch)
            
        case .qr:
            handleQR(dispatch)
        }
    }
}

extension PaymentsTransfersFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersFlowEvent<Profile, QR>
    typealias Effect = PaymentsTransfersFlowEffect
}

private extension PaymentsTransfersFlowEffectHandler {
    
    func handleProfile(
        _ dispatch: @escaping Dispatch
    ) {
        microServices.makeProfile { dispatch(.profile($0)) }
    }
    
    func handleQR(
        _ dispatch: @escaping Dispatch
    ) {
        microServices.makeQR { dispatch(.qr($0)) }
    }
}

import XCTest

final class PaymentsTransfersFlowEffectHandlerTests: PaymentsTransfersFlowTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, makeProfile, makeQR) = makeSUT()
        
        XCTAssertEqual(makeProfile.callCount, 0)
        XCTAssertEqual(makeQR.callCount, 0)
    }
    
    // MARK: - profile
    
    func test_profile_shouldCallMakeProfile() {
        
        let (sut, makeProfile, _) = makeSUT()
        
        sut.handleEffect(.profile) { _ in }
        
        XCTAssertEqual(makeProfile.callCount, 1)
    }
    
    func test_profile_shouldDeliverProfile() {
        
        let profile = makeProfile()
        let (sut, makeProfile, _) = makeSUT()
        
        expect(sut, with: .profile, toDeliver: .profile(profile)) {
            
            makeProfile.complete(with: profile)
        }
    }
    
    // MARK: - QR
    
    func test_qr_shouldCallMakeQR() {
        
        let (sut, _, makeQR) = makeSUT()
        
        sut.handleEffect(.qr) { _ in }
        
        XCTAssertEqual(makeQR.callCount, 1)
    }
    
    func test_qr_shouldDeliverQR() {
        
        let qr = makeQR()
        let (sut, _, makeQR) = makeSUT()
        
        expect(sut, with: .qr, toDeliver: .qr(qr)) {
            
            makeQR.complete(with: qr)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersFlowEffectHandler<Profile, QR>
    private typealias MakeProfileSpy = Spy<Void, Profile>
    private typealias MakeQRSpy = Spy<Void, QR>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeProfile: MakeProfileSpy,
        makeQR: MakeQRSpy
    ) {
        let makeProfile = MakeProfileSpy()
        let makeQR = MakeQRSpy()
        let sut = SUT(microServices: .init(
            makeProfile: makeProfile.process(completion:),
            makeQR: makeQR.process(completion:)
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeProfile, file: file, line: line)
        trackForMemoryLeaks(makeQR, file: file, line: line)
        
        return (sut, makeProfile, makeQR)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var receivedEvents = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            receivedEvents.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(receivedEvents, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}

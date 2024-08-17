//
//  PaymentsTransfersFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

enum PaymentsTransfersFlowEvent<Profile> {
    
    case profile(Profile)
}

extension PaymentsTransfersFlowEvent: Equatable where Profile: Equatable {}

enum PaymentsTransfersFlowEffect: Equatable {
    
    case profile
}

struct PaymentsTransfersFlowEffectHandlerMicroServices<Profile> {
    
    let makeProfile: MakeProfile
}

extension PaymentsTransfersFlowEffectHandlerMicroServices {
    
    typealias MakeProfileCompletion = (Profile) -> Void
    typealias MakeProfile = (@escaping MakeProfileCompletion) -> Void
}

final class PaymentsTransfersFlowEffectHandler<Profile> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = PaymentsTransfersFlowEffectHandlerMicroServices<Profile>
}

extension PaymentsTransfersFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .profile:
            handleProfile(dispatch)
        }
    }
}

extension PaymentsTransfersFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersFlowEvent<Profile>
    typealias Effect = PaymentsTransfersFlowEffect
}

private extension PaymentsTransfersFlowEffectHandler {

    func handleProfile(
        _ dispatch: @escaping Dispatch
    ) {
        microServices.makeProfile { dispatch(.profile($0)) }
    }
}

import XCTest

final class PaymentsTransfersFlowEffectHandlerTests: XCTestCase {
    
    // MARK: - init

    func test_init_shouldNotCallCollaborators() {
        
        let (_, makeProfile) = makeSUT()
        
        XCTAssertEqual(makeProfile.callCount, 0)
    }
    
    // MARK: - profile
    
    func test_profile_shouldCallMakeProfile() {
        
        let (sut, makeProfile) = makeSUT()

        sut.handleEffect(.profile) { _ in }
        
        XCTAssertEqual(makeProfile.callCount, 1)
    }
    
    func test_profile_shouldDeliverProfile() {
        
        let profile = makeProfile()
        let (sut, makeProfile) = makeSUT()

        expect(sut, with: .profile, toDeliver: .profile(profile)) {
            
            makeProfile.complete(with: profile)
        }
    }
    
    // MARK: - Helpers
    
    private typealias Profile = String
    private typealias SUT = PaymentsTransfersFlowEffectHandler<Profile>
    private typealias MakeProfileSpy = Spy<Void, Profile>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeProfile: MakeProfileSpy
    ) {
        let makeProfile = MakeProfileSpy()
        let sut = SUT(microServices: .init(
            makeProfile: makeProfile.process(completion:)
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeProfile, file: file, line: line)
        
        return (sut, makeProfile)
    }
    
    private func makeProfile(
        _ value: String = anyMessage()
    ) -> Profile {
        
        return value
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
    }}

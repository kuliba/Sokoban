//
//  PaymentsTransfersToolbarEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

import XCTest

final class PaymentsTransfersToolbarEffectHandlerTests: PaymentsTransfersToolbarTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, makeProfile, makeQR) = makeSUT()
        
        XCTAssertEqual(makeProfile.callCount, 0)
        XCTAssertEqual(makeQR.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - select
    
    func test_select_profile_shouldCallMakeProfile() {
        
        let (sut, makeProfile, _) = makeSUT()
        
        sut.handleEffect(.select(.profile)) { _ in }
        
        XCTAssertEqual(makeProfile.callCount, 1)
    }
    
    func test_select_profile_shouldDeliverProfile() {
        
        let profile = makeProfile()
        let (sut, makeProfile, _) = makeSUT()
        
        expect(sut, with: .select(.profile), toDeliver: .profile(profile)) {
            
            makeProfile.complete(with: profile)
        }
    }
    
    func test_select_qr_shouldCallMakeProfile() {
        
        let (sut, _, makeQR) = makeSUT()
        
        sut.handleEffect(.select(.qr)) { _ in }
        
        XCTAssertEqual(makeQR.callCount, 1)
    }
    
    func test_select_qr_shouldDeliverQR() {
        
        let qr = makeQR()
        let (sut, _, makeQR) = makeSUT()
        
        expect(sut, with: .select(.qr), toDeliver: .qr(qr)) {
            
            makeQR.complete(with: qr)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersToolbarEffectHandler<Profile, QR>
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
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}

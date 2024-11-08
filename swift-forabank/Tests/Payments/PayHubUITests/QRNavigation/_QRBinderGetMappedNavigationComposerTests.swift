//
//  _QRBinderGetMappedNavigationComposerTests.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHubUI
import XCTest

final class _QRBinderGetMappedNavigationComposerTests: QRBinderTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.makeMixedPicker.callCount, 0)
        XCTAssertEqual(spies.makeQRFailure.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - missingINN
    
    func test_getNavigation_missingINN_shouldCallMakeQRFailure() {
        
        let qrCode = makeQRCode()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(mapped: .missingINN(qrCode))
        
        XCTAssertNoDiff(spies.makeQRFailure.payloads, [.missingINN(qrCode)])
    }
    
    func test_getNavigation_missingINN_shouldDeliverQRFailure() {
        
        let qrFailure = makeQRFailure()
        
        expect(
            makeSUT(qrFailure: qrFailure).sut,
            with: .missingINN(makeQRCode()),
            toDeliver: .qrFailure(.init(qrFailure))
        )
    }
    
    func test_getNavigation_missingINN_shouldNotifyWithDismissOnQRFailureClose() {
        
        expect(
            makeSUT(qrFailure: makeQRFailure()).sut,
            with: .missingINN(makeQRCode()),
            notifyWith: [.dismiss],
            for: { self.qrFailure($0)?.close() }
        )
    }
    
    func test_getNavigation_missingINN_shouldNotifyWithDismissOnQRFailureScanQR() {
        
        expect(
            makeSUT(qrFailure: makeQRFailure()).sut,
            with: .missingINN(makeQRCode()),
            notifyWith: [.dismiss],
            for: { self.qrFailure($0)?.scanQR() }
        )
    }
    
    // MARK: - mixedPicker
    
    func test_getNavigation_mixedPicker_shouldCallMakeMixedPickerWithPayload() {
        
        let mixed = makeMakeMixedPickerPayload()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(mapped: .mixed(mixed))
        
        XCTAssertNoDiff(spies.makeMixedPicker.payloads, [mixed])
    }
    
    func test_getNavigation_mixedPicker_shouldDeliverMixedPicker() {
        
        let mixedPicker = makeMixedPicker()
        
        expect(
            makeSUT(mixedPicker: mixedPicker).sut,
            with: .mixed(makeMakeMixedPickerPayload()),
            toDeliver: .mixedPicker(.init(mixedPicker))
        )
    }
    
    func test_getNavigation_mixedPicker_shouldNotifyWithChatOnMixedPickerAddCompany() {
        
        expect(
            makeSUT(mixedPicker: makeMixedPicker()).sut,
            with: .mixed(makeMakeMixedPickerPayload()),
            notifyWith: [.select(.outside(.chat))],
            for: { self.mixedPicker($0)?.addCompany() }
        )
    }
    
    func test_getNavigation_mixedPicker_shouldNotifyWithDismissOnMixedPickerClose() {
        
        expect(
            makeSUT(mixedPicker: makeMixedPicker()).sut,
            with: .mixed(makeMakeMixedPickerPayload()),
            notifyWith: [.dismiss],
            for: { self.mixedPicker($0)?.close() }
        )
    }
    
    func test_getNavigation_mixedPicker_shouldNotifyWithDismissOnMixedPickerScanQR() {
        
        expect(
            makeSUT(mixedPicker: makeMixedPicker()).sut,
            with: .mixed(makeMakeMixedPickerPayload()),
            notifyWith: [.dismiss],
            for: { self.mixedPicker($0)?.scanQR() }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MappedNavigationComposer
    
    private struct Spies {

        let makeQRFailure: MakeQRFailure
        let makeMixedPicker: MakeMixedPicker
    }
    
    private func makeSUT(
        payments: Payments? = nil,
        qrFailure: QRFailure? = nil,
        mixedPicker: MixedPicker? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let spies = Spies(
            makeQRFailure: .init(stubs: [qrFailure ?? makeQRFailure()]),
            makeMixedPicker: .init(stubs: [mixedPicker ?? makeMixedPicker()])
        )
        let sut = SUT(
            microServices: .init(
                makeQRFailure: spies.makeQRFailure.call,
                makeMixedPicker: spies.makeMixedPicker.call
            ),
            witnesses: .init(
                addCompany: .init(mixedPicker: { $0.addCompanyPublisher }),
                isClosed: .init(
                    mixedPicker: { $0.isClosed },
                    qrFailure: { $0.isClosed }
                ),
                scanQR: .init(
                    mixedPicker: { $0.scanQRPublisher },
                    qrFailure: { $0.scanQRPublisher }
                )
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spies.makeMixedPicker, file: file, line: line)
        trackForMemoryLeaks(spies.makeQRFailure, file: file, line: line)
        
        return (sut, spies)
    }
    
    private func expect(
        _ sut: SUT,
        with mapped: SUT.Mapped,
        toDeliver expectedNavigation: EquatableNavigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(mapped: mapped, notify: { _ in }) {
            
            XCTAssertNoDiff(self.equatable($0), expectedNavigation, "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func expect(
        _ sut: SUT,
        with mapped: SUT.Mapped,
        notifyWith expectedEvents: [SUT.FlowDomain.NotifyEvent],
        for destinationAction: @escaping (Navigation) -> Void,
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedEvents = [SUT.FlowDomain.NotifyEvent]()
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(
            mapped: mapped,
            notify: { receivedEvents.append($0) }
        ) {
            destinationAction($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedEvents.map(equatable), expectedEvents.map(equatable), "Expected \(expectedEvents), but got \(receivedEvents) instead.", file: file, line: line)
    }
    
    // MARK: - DSL
    
    func mixedPicker(_ navigation: Navigation) -> MixedPicker? {
        
        qrNavigation(navigation)?.mixedPicker
    }
    
    func payments(_ navigation: Navigation) -> Payments? {
        
        qrNavigation(navigation)?.payments
    }
    
    func qrFailure(_ navigation: Navigation) -> QRFailure? {
        
        qrNavigation(navigation)?.qrFailure
    }
    
    func qrNavigation(_ navigation: Navigation) -> Navigation.QRNavigation? {
        
        guard case let .qrNavigation(qrNavigation) = navigation
        else { return nil }
        
        return qrNavigation
    }
}

// MARK: - DSL

private extension _QRBinderGetMappedNavigationComposer {
    
    func getNavigation(
        mapped: Mapped
    ) {
        self.getNavigation(mapped: mapped, notify: { _ in }, completion: { _ in })
    }
}

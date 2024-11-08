//
//  QRBinderGetNavigationComposerTests.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHubUI
import XCTest

final class QRBinderGetNavigationComposerTests: QRBinderTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.makeMixedPicker.callCount, 0)
        XCTAssertEqual(spies.makePayments.callCount, 0)
        XCTAssertEqual(spies.makeQRFailure.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - c2bSubscribe
    
    func test_getNavigation_c2bSubscribe_shouldCallMakePaymentsWithC2BSubscribeURL() {
        
        let url = anyURL()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .c2bSubscribeURL(url))
        
        XCTAssertNoDiff(spies.makePayments.payloads, [.c2bSubscribe(url)])
    }
    
    func test_getNavigation_c2bSubscribe_shouldDeliverPayments() {
        
        let payments = makePayments()
        
        expect(
            makeSUT(payments: payments).sut,
            with: .c2bSubscribeURL(anyURL()),
            toDeliver: .payments(.init(payments))
        )
    }
    
    func test_getNavigation_c2bSubscribe_shouldNotifyWithDismissOnPaymentsClose() {
        
        expect(
            makeSUT(payments: makePayments()).sut,
            with: .c2bSubscribeURL(anyURL()),
            notifyWith: [.dismiss],
            for: { self.payments($0)?.close() }
        )
    }
    
    func test_getNavigation_c2bSubscribe_shouldNotifyWithDismissOnPaymentsScanQR() {
        
        expect(
            makeSUT(payments: makePayments()).sut,
            with: .c2bSubscribeURL(anyURL()),
            notifyWith: [.dismiss],
            for: { self.payments($0)?.scanQR() }
        )
    }
    
    // MARK: - c2b
    
    func test_getNavigation_c2b_shouldCallMakePaymentsWithC2BURL() {
        
        let url = anyURL()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .c2bURL(url))
        
        XCTAssertNoDiff(spies.makePayments.payloads, [.c2b(url)])
    }
    
    func test_getNavigation_c2b_shouldDeliverPayments() {
        
        let payments = makePayments()
        
        expect(
            makeSUT(payments: payments).sut,
            with: .c2bURL(anyURL()),
            toDeliver: .payments(.init(payments))
        )
    }
    
    func test_getNavigation_c2b_shouldNotifyWithDismissOnPaymentsClose() {
        
        expect(
            makeSUT(payments: makePayments()).sut,
            with: .c2bURL(anyURL()),
            notifyWith: [.dismiss],
            for: { self.payments($0)?.close() }
        )
    }
    
    func test_getNavigation_c2b_shouldNotifyWithDismissOnPaymentsScanQR() {
        
        expect(
            makeSUT(payments: makePayments()).sut,
            with: .c2bURL(anyURL()),
            notifyWith: [.dismiss],
            for: { self.payments($0)?.scanQR() }
        )
    }
    
    // MARK: - failure
    
    func test_getNavigation_failure_shouldCallMakeQRFailureWithQRCode() {
        
        let qrCode = makeQRCode()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .failure(qrCode))
        
        XCTAssertNoDiff(spies.makeQRFailure.payloads, [.qrCode(qrCode)])
    }
    
    func test_getNavigation_failure_shouldDeliverQRFailure() {
        
        let qrFailure = makeQRFailure()
        
        expect(
            makeSUT(qrFailure: qrFailure).sut,
            with: .failure(makeQRCode()),
            toDeliver: .qrFailure(.init(qrFailure))
        )
    }
    
    func test_getNavigation_failure_shouldNotifyWithDismissOnQRFailureClose() {
        
        expect(
            makeSUT(qrFailure: makeQRFailure()).sut,
            with: .failure(makeQRCode()),
            notifyWith: [.dismiss],
            for: { self.qrFailure($0)?.close() }
        )
    }
    
    func test_getNavigation_failure_shouldNotifyWithDismissOnQRFailureScanQR() {
        
        expect(
            makeSUT(qrFailure: makeQRFailure()).sut,
            with: .failure(makeQRCode()),
            notifyWith: [.dismiss],
            for: { self.qrFailure($0)?.scanQR() }
        )
    }
    
    // MARK: - missingINN
    
    func test_getNavigation_missingINN_shouldCallMakeQRFailure() {
        
        let qrCode = makeQRCode()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .mapped(.missingINN(qrCode)))
        
        XCTAssertNoDiff(spies.makeQRFailure.payloads, [.missingINN(qrCode)])
    }
    
    func test_getNavigation_missingINN_shouldDeliverQRFailure() {
        
        let qrFailure = makeQRFailure()
        
        expect(
            makeSUT(qrFailure: qrFailure).sut,
            with: .mapped(.missingINN(makeQRCode())),
            toDeliver: .qrFailure(.init(qrFailure))
        )
    }
    
    func test_getNavigation_missingINN_shouldNotifyWithDismissOnQRFailureClose() {
        
        expect(
            makeSUT(qrFailure: makeQRFailure()).sut,
            with: .mapped(.missingINN(makeQRCode())),
            notifyWith: [.dismiss],
            for: { self.qrFailure($0)?.close() }
        )
    }
    
    func test_getNavigation_missingINN_shouldNotifyWithDismissOnQRFailureScanQR() {
        
        expect(
            makeSUT(qrFailure: makeQRFailure()).sut,
            with: .mapped(.missingINN(makeQRCode())),
            notifyWith: [.dismiss],
            for: { self.qrFailure($0)?.scanQR() }
        )
    }
    
    // MARK: - mixedPicker
    
    func test_getNavigation_mixedPicker_shouldCallMakeMixedPickerWithPayload() {
        
        let mixed = makeMakeMixedPickerPayload()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .mapped(.mixed(mixed)))
        
        XCTAssertNoDiff(spies.makeMixedPicker.payloads, [mixed])
    }
    
    func test_getNavigation_mixedPicker_shouldDeliverMixedPicker() {
        
        let mixedPicker = makeMixedPicker()
        
        expect(
            makeSUT(mixedPicker: mixedPicker).sut,
            with: .mapped(.mixed(makeMakeMixedPickerPayload())),
            toDeliver: .mixedPicker(.init(mixedPicker))
        )
    }
    
    func test_getNavigation_mixedPicker_shouldNotifyWithChatOnMixedPickerAddCompany() {
        
        expect(
            makeSUT(mixedPicker: makeMixedPicker()).sut,
            with: .mapped(.mixed(makeMakeMixedPickerPayload())),
            notifyWith: [.select(.outside(.chat))],
            for: { self.mixedPicker($0)?.addCompany() }
        )
    }
    
    func test_getNavigation_mixedPicker_shouldNotifyWithDismissOnMixedPickerClose() {
        
        expect(
            makeSUT(mixedPicker: makeMixedPicker()).sut,
            with: .mapped(.mixed(makeMakeMixedPickerPayload())),
            notifyWith: [.dismiss],
            for: { self.mixedPicker($0)?.close() }
        )
    }
    
    func test_getNavigation_mixedPicker_shouldNotifyWithDismissOnMixedPickerScanQR() {
        
        expect(
            makeSUT(mixedPicker: makeMixedPicker()).sut,
            with: .mapped(.mixed(makeMakeMixedPickerPayload())),
            notifyWith: [.dismiss],
            for: { self.mixedPicker($0)?.scanQR() }
        )
    }
    
    // MARK: - multiplePicker
    
    func test_getNavigation_multiplePicker_shouldCallMakeMultiplePickerWithPayload() {
        
        let multiple = makeMakeMultiplePickerPayload()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .mapped(.multiple(multiple)))
        
        XCTAssertNoDiff(spies.makeMultiplePicker.payloads, [multiple])
    }
    
    func test_getNavigation_multiplePicker_shouldDeliverMultiplePicker() {
        
        let multiplePicker = makeMultiplePicker()
        
        expect(
            makeSUT(multiplePicker: multiplePicker).sut,
            with: .mapped(.multiple(makeMakeMultiplePickerPayload())),
            toDeliver: .multiplePicker(.init(multiplePicker))
        )
    }
    
    func test_getNavigation_multiplePicker_shouldNotifyWithChatOnMultiplePickerAddCompany() {
        
        expect(
            makeSUT(multiplePicker: makeMultiplePicker()).sut,
            with: .mapped(.multiple(makeMakeMultiplePickerPayload())),
            notifyWith: [.select(.outside(.chat))],
            for: { self.multiplePicker($0)?.addCompany() }
        )
    }
    
    func test_getNavigation_multiplePicker_shouldNotifyWithDismissOnMultiplePickerClose() {
        
        expect(
            makeSUT(multiplePicker: makeMultiplePicker()).sut,
            with: .mapped(.multiple(makeMakeMultiplePickerPayload())),
            notifyWith: [.dismiss],
            for: { self.multiplePicker($0)?.close() }
        )
    }
    
    func test_getNavigation_multiplePicker_shouldNotifyWithDismissOnMultiplePickerScanQR() {
        
        expect(
            makeSUT(multiplePicker: makeMultiplePicker()).sut,
            with: .mapped(.multiple(makeMakeMultiplePickerPayload())),
            notifyWith: [.dismiss],
            for: { self.multiplePicker($0)?.scanQR() }
        )
    }
    
    // MARK: - none
    
    func test_getNavigation_none_shouldCallMakePaymentsWithQRCode() {
        
        let qrCode = makeQRCode()
        let (sut, spies) = makeSUT()
        
        sut.getNavigation(qrResult: .mapped(.none(qrCode)))
        
        XCTAssertNoDiff(spies.makePayments.payloads, [.details(qrCode)])
    }
    
    func test_getNavigation_none_shouldDeliverPayments() {
        
        let payments = makePayments()
        
        expect(
            makeSUT(payments: payments).sut,
            with: .mapped(.none(makeQRCode())),
            toDeliver: .payments(.init(payments))
        )
    }
    
    func test_getNavigation_none_shouldNotifyWithDismissOnPaymentsClose() {
        
        expect(
            makeSUT(payments: makePayments()).sut,
            with: .mapped(.none(makeQRCode())),
            notifyWith: [.dismiss],
            for: { self.payments($0)?.close() }
        )
    }
    
    func test_getNavigation_none_shouldNotifyWithDismissOnPaymentsScanQR() {
        
        expect(
            makeSUT(payments: makePayments()).sut,
            with: .mapped(.none(makeQRCode())),
            notifyWith: [.dismiss],
            for: { self.payments($0)?.scanQR() }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NavigationComposer
    
    private struct Spies {
        
        let makePayments: MakePayments
        let makeQRFailure: MakeQRFailure
        let makeMixedPicker: MakeMixedPicker
        let makeMultiplePicker: MakeMultiplePicker
    }
    
    private func makeSUT(
        payments: Payments? = nil,
        qrFailure: QRFailure? = nil,
        mixedPicker: MixedPicker? = nil,
        multiplePicker: MultiplePicker? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let spies = Spies(
            makePayments: .init(stubs: [payments ?? makePayments()]),
            makeQRFailure: .init(stubs: [qrFailure ?? makeQRFailure()]),
            makeMixedPicker: .init(stubs: [mixedPicker ?? makeMixedPicker()]),
            makeMultiplePicker: .init(stubs: [multiplePicker ?? makeMixedPicker()])
        )
        let sut = SUT(
            microServices: .init(
                makeQRFailure: spies.makeQRFailure.call,
                makePayments: spies.makePayments.call,
                makeMixedPicker: spies.makeMixedPicker.call,
                makeMultiplePicker: spies.makeMultiplePicker.call
            ),
            witnesses: .init(
                addCompany: .init(
                    mixedPicker: { $0.addCompanyPublisher },
                    multiplePicker: { $0.addCompanyPublisher }
                ),
                isClosed: .init(
                    mixedPicker: { $0.isClosed },
                    multiplePicker: { $0.isClosed },
                    payments: { $0.isClosed },
                    qrFailure: { $0.isClosed }
                ),
                scanQR: .init(
                    mixedPicker: { $0.scanQRPublisher },
                    multiplePicker: { $0.scanQRPublisher },
                    payments: { $0.scanQRPublisher },
                    qrFailure: { $0.scanQRPublisher }
                )
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spies.makeMixedPicker, file: file, line: line)
        trackForMemoryLeaks(spies.makePayments, file: file, line: line)
        trackForMemoryLeaks(spies.makeQRFailure, file: file, line: line)
        
        return (sut, spies)
    }
    
    private func expect(
        _ sut: SUT,
        with qrResult: SUT.Select.QRResult,
        toDeliver expectedNavigation: EquatableNavigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, with: .qrResult(qrResult), toDeliver: expectedNavigation, on: action, timeout: timeout, file: file, line: line)
    }
    
    private func expect(
        _ sut: SUT,
        with select: SUT.Select,
        toDeliver expectedNavigation: EquatableNavigation,
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(select: select, notify: { _ in }) {
            
            XCTAssertNoDiff(self.equatable($0), expectedNavigation, "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func expect(
        _ sut: SUT,
        with qrResult: SUT.Select.QRResult,
        notifyWith expectedEvents: [SUT.FlowDomain.NotifyEvent],
        for destinationAction: @escaping (Navigation) -> Void,
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, with: .qrResult(qrResult), notifyWith: expectedEvents, for: destinationAction, on: action, file: file, line: line)
    }
    
    private func expect(
        _ sut: SUT,
        with select: SUT.Select,
        notifyWith expectedEvents: [SUT.FlowDomain.NotifyEvent],
        for destinationAction: @escaping (Navigation) -> Void,
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedEvents = [SUT.FlowDomain.NotifyEvent]()
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(
            select: select,
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
    
    func multiplePicker(_ navigation: Navigation) -> MultiplePicker? {
        
        qrNavigation(navigation)?.multiplePicker
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

private extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        qrResult: Select.QRResult
    ) {
        self.getNavigation(select: .qrResult(qrResult), notify: { _ in }, completion: { _ in })
    }
}

extension QRNavigation {
    
    var mixedPicker: MixedPicker? {
        
        guard case let .mixedPicker(node) = self else { return nil }
        
        return node.model
    }
    
    var multiplePicker: MultiplePicker? {
        
        guard case let .multiplePicker(node) = self else { return nil }
        
        return node.model
    }
    
    var payments: Payments? {
        
        guard case let .payments(node) = self else { return nil }
        
        return node.model
    }
    
    var qrFailure: QRFailure? {
        
        guard case let .qrFailure(node) = self else { return nil }
        
        return node.model
    }
}

//
//  QRNavigationComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.10.2024.
//

import CombineSchedulers
@testable import ForaBank
import ForaTools
import SberQR
import XCTest

final class QRNavigationComposerTests: QRNavigationTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, microServices) = makeSUT()
        
        XCTAssertEqual(microServices.makeInternetTV.callCount, 0)
        XCTAssertEqual(microServices.makePayments.callCount, 0)
        XCTAssertEqual(microServices.makeQRFailure.callCount, 0)
        XCTAssertEqual(microServices.makeQRFailureWithQR.callCount, 0)
        XCTAssertEqual(microServices.makeSberPaymentComplete.callCount, 0)
        XCTAssertEqual(microServices.makeProviderPicker.callCount, 0)
        XCTAssertEqual(microServices.makeOperatorSearch.callCount, 0)
        XCTAssertEqual(microServices.makeSberQR.callCount, 0)
        XCTAssertEqual(microServices.makeServicePicker.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - qrResult: c2bSubscribe
    
    func test_c2bSubscribe_shouldCallMakeC2BSubscribeWithURL() {
        
        let url = anyURL()
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .c2bSubscribeURL(url))
        
        XCTAssertNoDiff(microServices.makePayments.payloads, [.source(.c2bSubscribe(url))])
    }
    
    func test_c2bSubscribe_shouldDeliverPayments() {
        
        let payments = makePaymentsModel()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bSubscribeURL(anyURL()),
            toDeliver: .payments(.init(payments)),
            on: { microServices.makePayments.complete(with: payments) }
        )
    }
    
    func test_c2bSubscribe_shouldDeliverDismissEventOnC2BSubscribeClose() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bSubscribeURL(anyURL()),
            delivers: .dismiss,
            for: { $0.payments?.closeAction() },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    func test_c2bSubscribe_shouldDeliverScanQREventOnC2BSubscribeScanQRCode() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bSubscribeURL(anyURL()),
            delivers: .scanQR,
            for: { $0.payments?.scanQRCode() },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    func test_c2bSubscribe_shouldDeliverContactAbroadEventOnC2BSubscribeContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bSubscribeURL(anyURL()),
            delivers: .contactAbroad(source),
            for: { $0.payments?.contactAbroad(source: source) },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    // MARK: - qrResult: c2b
    
    func test_c2b_shouldCallMakeC2BWithURL() {
        
        let url = anyURL()
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .c2bURL(url))
        
        XCTAssertNoDiff(microServices.makePayments.payloads, [.source(.c2b(url))])
    }
    
    func test_c2b_shouldDeliverPayments() {
        
        let payments = makePaymentsModel()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bURL(anyURL()),
            toDeliver: .payments(.init(payments)),
            on: { microServices.makePayments.complete(with: payments) }
        )
    }
    
    func test_c2b_shouldDeliverDismissEventOnC2BClose() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bURL(anyURL()),
            delivers: .dismiss,
            for: { $0.payments?.closeAction() },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    func test_c2b_shouldDeliverScanQREventOnC2BScanQRCode() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bURL(anyURL()),
            delivers: .scanQR,
            for: { $0.payments?.scanQRCode() },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    func test_c2b_shouldDeliverContactAbroadEventOnC2BContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bURL(anyURL()),
            delivers: .contactAbroad(source),
            for: { $0.payments?.contactAbroad(source: source) },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    // MARK: - qrResult: failure
    
    func test_failure_shouldCallMakeQRFailureWithQR() {
        
        let qrCode = makeQR()
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .failure(qrCode))
        
        XCTAssertNoDiff(microServices.makeQRFailureWithQR.payloads.map(\.qrCode), [qrCode])
    }
    
    func test_failure_shouldDeliverFailure() {
        
        let failure = makeQRFailed()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .failure(makeQR()),
            toDeliver: .failure(.init(failure)),
            on: { microServices.makeQRFailureWithQR.complete(with: failure) }
        )
    }
    
    func test_failure_shouldDeliverOutsideChatEventOnFailureChatAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.getNavigation(with: .failure(makeQR()), notify: { events.append($0) })
        microServices.makeQRFailureWithQR.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events.map(\.equatable), [.outside(.chat)])
    }
    
    func test_failure_shouldDeliverDetailPaymentEventOnFailureDetailPaymentAction() {
        
        let qrCode = makeQR()
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.getNavigation(with: .failure(makeQR()), notify: { events.append($0) })
        microServices.makeQRFailureWithQR.payloads.first.map(\.detailPayment)?(qrCode)
        
        XCTAssertNoDiff(events.map(\.equatable), [.detailPayment(qrCode)])
    }
    
    // MARK: - qrResult: mapped: missingINN
    
    func test_missingINN_shouldCallMakeQRFailure() {
        
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .mapped(.missingINN))
        
        XCTAssertEqual(microServices.makeQRFailure.payloads.count, 1)
    }
    
    func test_missingINN_shouldDeliverFailureOnMissingINN() {
        
        let failure = makeQRFailed()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.missingINN),
            toDeliver: .failure(.init(failure)),
            on: { microServices.makeQRFailure.complete(with: failure) }
        )
    }
    
    func test_missingINN_shouldDeliverOutsideChatEventOnFailureChatAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.getNavigation(with: .mapped(.missingINN), notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events.map(\.equatable), [.outside(.chat)])
    }
    
    func test_missingINN_shouldDeliverDetailPaymentEventOnFailureDetailPaymentAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.getNavigation(with: .mapped(.missingINN), notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.detailPayment)?()
        
        XCTAssertNoDiff(events.map(\.equatable), [.detailPayment(nil)])
    }
    
    // MARK: - qrResult: mapped: mixed
    
    func test_mapped_mixed_shouldCallMakeProviderPickerWithPayload() {
        
        let (mixed, qrCode, qrMapping) = makeMixed()
        let result: QRModelResult = .mapped(.mixed(.init(operators: mixed, qrCode: qrCode, qrMapping: qrMapping)))
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: result)
        
        XCTAssertNoDiff(microServices.makeProviderPicker.payloads, [
            .init(mixed: mixed, qrCode: qrCode, qrMapping: qrMapping)
        ])
    }
    
    func test_mapped_mixed_shouldDeliverProviderPicker() {
        
        let picker = makeProviderPicker()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMixed(),
            toDeliver: .providerPicker(.init(picker)),
            on: { microServices.makeProviderPicker.complete(with: picker) }
        )
    }
    
#warning("FIXME")
    //    func test_mapped_mixed_shouldDeliverIsLoadingTrueEventOnProviderPickerEvent() {
    //
    //    let (sut, microServices) = makeSUT()
    //
    //        expect(
    //            sut,
    //            result: makeMappedMixed(),
    //            delivers: .isLoading(true),
    //            for: { $0.providerPickerSetIsLoading(to: true) },
    //            on: { makeProviderPicker.complete(with: makeProviderPicker()) }
    //        )
    //    }
    //
    //    func test_mapped_mixed_shouldDeliverIsLoadingFalseEventOnProviderPickerEvent() {
    //
    //    let (sut, microServices) = makeSUT()
    //
    //        expect(
    //            sut,
    //            result: makeMappedMixed(),
    //            delivers: .isLoading(false),
    //            for: { $0.providerPickerSetIsLoading(to: false) },
    //            on: { makeProviderPicker.complete(with: makeProviderPicker()) }
    //        )
    //    }
    
    func test_mapped_mixed_shouldDeliverOutsideChatEventOnProviderPickerEvent() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMixed(),
            delivers: .outside(.chat),
            for: { $0.providerPickerGoTo(to: .addCompany) },
            on: { microServices.makeProviderPicker.complete(with: makeProviderPicker()) }
        )
    }
    
    func test_mapped_mixed_shouldDeliverOutsideMainEventOnProviderPickerEvent() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMixed(),
            delivers: .outside(.main),
            for: { $0.providerPickerGoTo(to: .main) },
            on: { microServices.makeProviderPicker.complete(with: makeProviderPicker()) }
        )
    }
    
    func test_mapped_mixed_shouldDeliverOutsidePaymentsEventOnProviderPickerEvent() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMixed(),
            delivers: .outside(.payments),
            for: { $0.providerPickerGoTo(to: .payments) },
            on: { microServices.makeProviderPicker.complete(with: makeProviderPicker()) }
        )
    }
    
    func test_mapped_mixed_shouldDeliverOutsideScanQREventOnProviderPickerEvent() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMixed(),
            delivers: .scanQR,
            for: { $0.providerPickerGoTo(to: .scanQR) },
            on: { microServices.makeProviderPicker.complete(with: makeProviderPicker()) }
        )
    }
    
    // MARK: - qrResult: mapped: multiple
    
    func test_mapped_multiple_shouldCallMakeOperatorSearchWithPayload() {
        
        let (multiple, qrCode, qrMapping) = makeMultiple()
        let result: QRModelResult = .mapped(.multiple(multiple, qrCode, qrMapping))
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: result)
        
        let payloads = microServices.makeOperatorSearch.payloads
        XCTAssertNoDiff(payloads.map(\.multiple), [multiple])
        XCTAssertNoDiff(payloads.map(\.qrCode), [qrCode])
        XCTAssertNoDiff(payloads.map(\.qrMapping), [qrMapping])
        
        // TODO: - add tests for chat/detailPayment/dismiss actions in payload
    }
    
    func test_mapped_multiple_shouldDeliverOperatorSearch() {
        
        let search = makeOperatorSearch()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMultiple(),
            toDeliver: .operatorSearch(.init(search)),
            on: { microServices.makeOperatorSearch.complete(with: search) }
        )
    }
    
    // TODO: add tests for wrapper as in c2bSubscribe
    
    // MARK: - qrResult: mapped: none
    
    func test_mapped_none_shouldCallMakeDetailPaymentsWithQR() {
        
        let qrCode = makeQR()
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .mapped(.none(qrCode)))
        
        XCTAssertNoDiff(microServices.makePayments.payloads, [.qrCode(qrCode)])
    }
    
    func test_mapped_none_shouldDeliverPayments() {
        
        let payments = makePaymentsModel()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.none(makeQR())),
            toDeliver: .payments(.init(payments)),
            on: { microServices.makePayments.complete(with: payments) }
        )
    }
    
    func test_mapped_none_shouldDeliverDismissEventOnDetailPaymentsClose() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.none(makeQR())),
            delivers: .dismiss,
            for: { $0.payments?.closeAction() },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    func test_mapped_none_shouldDeliverScanQREventOnDetailPaymentsScanQRCode() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.none(makeQR())),
            delivers: .scanQR,
            for: { $0.payments?.scanQRCode() },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    func test_mapped_none_shouldDeliverContactAbroadEventOnDetailPaymentsContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.none(makeQR())),
            delivers: .contactAbroad(source),
            for: { $0.payments?.contactAbroad(source: source) },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    // MARK: - qrResult: mapped: provider
    
    func test_mapped_provider_shouldCallMakeServicePickerWithPayload() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .mapped(.provider(payload)))
        
        XCTAssertNoDiff(microServices.makeServicePicker.payloads, [payload])
    }
    
    func test_mapped_provider_shouldDeliverServicePicker() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let picker = makeServicePicker()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.provider(payload)),
            toDeliver: .servicePicker(.init(picker)),
            on: { microServices.makeServicePicker.complete(with: picker) }
        )
    }
    
#warning("FIXME")
    //    func test_mapped_provider_shouldDeliverIsLoadingTrueEventOnServicePickerEvent() {
    //
    //    let (sut, microServices) = makeSUT()
    //
    //        expect(
    //            sut,
    //            result: makeMappedMixed(),
    //            delivers: .isLoading(true),
    //            for: { $0.providerPickerSetIsLoading(to: true) },
    //            on: { microServices.makeServicePicker.complete(with: makeServicePicker()) }
    //        )
    //    }
    //
    //    func test_mapped_provider_shouldDeliverIsLoadingFalseEventOnServicePickerEvent() {
    //
    //    let (sut, microServices) = makeSUT()
    //
    //        expect(
    //            sut,
    //            result: makeMappedMixed(),
    //            delivers: .isLoading(false),
    //            for: { $0.providerPickerSetIsLoading(to: false) },
    //            on: { microServices.makeServicePicker.complete(with: makeServicePicker()) }
    //        )
    //    }
    
    func test_mapped_provider_shouldDeliverOutsideChatEventOnServicePickerEvent() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.provider(payload)),
            delivers: .outside(.chat),
            for: { $0.servicePicker?.event(.goTo(.addCompany)) },
            on: { microServices.makeServicePicker.complete(with: makeServicePicker()) }
        )
    }
    
    func test_mapped_provider_shouldDeliverOutsideMainEventOnServicePickerEvent() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.provider(payload)),
            delivers: .outside(.main),
            for: { $0.servicePicker?.event(.goTo(.main)) },
            on: { microServices.makeServicePicker.complete(with: makeServicePicker()) }
        )
    }
    
    func test_mapped_provider_shouldDeliverOutsidePaymentsEventOnServicePickerEvent() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.provider(payload)),
            delivers: .outside(.payments),
            for: { $0.servicePicker?.event(.goTo(.payments)) },
            on: { microServices.makeServicePicker.complete(with: makeServicePicker()) }
        )
    }
    
    func test_mapped_provider_shouldDeliverScanQRNotifyEventOnServicePickerEvent() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.provider(payload)),
            delivers: .scanQR,
            for: { $0.servicePicker?.event(.goTo(.scanQR)) },
            on: { microServices.makeServicePicker.complete(with: makeServicePicker()) }
        )
    }
    
    // MARK: - qrResult: mapped: single
    
    func test_mapped_single_shouldCallMakeInternetTVWithPayload() {
        
        let (qrCode, qrMapping) = (makeQR(), makeQRMapping())
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .mapped(.single(
            makeSegmentedOperatorData(), qrCode, qrMapping
        )))
        
        XCTAssertNoDiff(microServices.makeInternetTV.payloads.map(\.0), [qrCode])
        XCTAssertNoDiff(microServices.makeInternetTV.payloads.map(\.1), [qrMapping])
    }
    
    func test_mapped_single_shouldDeliverInternetTV() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedSingle(),
            toDeliver: .internetTV,
            on: { microServices.makeInternetTV.complete(with: makeInternetTVModel()) }
        )
    }
    
    // MARK: - qrResult: mapped: source
    
    func test_mapped_source_shouldCallMakeSourcePaymentsWithPayload() {
        
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .mapped(.source(.avtodor)))
        
        XCTAssertNoDiff(microServices.makePayments.payloads, [.operationSource(.avtodor)])
    }
    
    func test_mapped_source_shouldDeliverPayments() {
        
        let payments = makePaymentsModel()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.source(.avtodor)),
            toDeliver: .payments(.init(payments)),
            on: { microServices.makePayments.complete(with: payments) }
        )
    }
    
    func test_mapped_source_shouldDeliverDismissEventOnSourcePaymentsClose() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.source(.avtodor)),
            delivers: .dismiss,
            for: { $0.payments?.closeAction() },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    func test_mapped_source_shouldDeliverScanQREventOnSourcePaymentsScanQRCode() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.source(.avtodor)),
            delivers: .scanQR,
            for: { $0.payments?.scanQRCode() },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    func test_mapped_source_shouldDeliverContactAbroadEventOnSourcePaymentsContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.source(.avtodor)),
            delivers: .contactAbroad(source),
            for: { $0.payments?.contactAbroad(source: source) },
            on: { microServices.makePayments.complete(with: makePaymentsModel()) }
        )
    }
    
    // MARK: - qrResult: sberQR
    
    func test_sberQR_shouldCallMakeSberQRWithURLInPayload() {
        
        let url = anyURL()
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .sberQR(url))
        
        XCTAssertEqual(microServices.makeSberQR.payloads.map(\.url), [url])
    }
    
    func test_sberQR_shouldCallMakeSberQRWithNotifyInPayload() {
        
        let sberState = makeSberQRConfirmPaymentState()
        let (sut, microServices) = makeSUT()
        var receivedEvents = [SUT.NotifyEvent]()
        
        sut.getNavigation(
            with: .sberQR(anyURL()),
            notify: { receivedEvents.append($0) }
        )
        microServices.makeSberQR.payloads.map(\.1).first?(sberState)
        
        XCTAssertNoDiff(receivedEvents.map(\.equatable), [.sberPay(sberState)])
    }
    
    func test_sberQR_shouldDeliverSberQRFailureOnMakeSberQRFailure() {
        
        let error = makeErrorMessage()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .sberQR(anyURL()),
            toDeliver: .sberQR(.failure(error)),
            on: { microServices.makeSberQR.complete(with: error) }
        )
    }
    
    func test_sberQR_shouldDeliverSberQROnMakeSberQRSuccess() {
        
        let sberQR = makeSberQR()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .sberQR(anyURL()),
            toDeliver: .sberQR(.success(.init(sberQR))),
            on: { microServices.makeSberQR.complete(with: sberQR) }
        )
    }
    
    // TODO: - add tests for associated type of `sberQR` case, otherwise nothing support the need of `SberQRConfirmPaymentViewModel`
    
    // MARK: - qrResult: url
    
    func test_url_shouldCallMakeQRFailure() {
        
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .url(anyURL()))
        
        XCTAssertEqual(microServices.makeQRFailure.payloads.count, 1)
    }
    
    func test_url_shouldDeliverFailure() {
        
        let failure = makeQRFailed()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .url(anyURL()),
            toDeliver: .failure(.init(failure)),
            on: { microServices.makeQRFailure.complete(with: failure) }
        )
    }
    
    func test_url_shouldNotifyWithOutsideChatOnChatAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.getNavigation(with: .url(anyURL()), notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events.map(\.equatable), [.outside(.chat)])
    }
    
    func test_url_shouldNotifyWithWithDetailPaymentAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.getNavigation(with: .url(anyURL()), notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.detailPayment)?()
        
        XCTAssertNoDiff(events.map(\.equatable), [.detailPayment(nil)])
    }
    
    // MARK: - qrResult: unknown
    
    func test_unknown_shouldCallMakeQRFailure() {
        
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(with: .unknown)
        
        XCTAssertEqual(microServices.makeQRFailure.payloads.count, 1)
    }
    
    func test_unknown_shouldDeliverFailure() {
        
        let failure = makeQRFailed()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .unknown,
            toDeliver: .failure(.init(failure)),
            on: { microServices.makeQRFailure.complete(with: failure) }
        )
    }
    
    func test_unknown_shouldNotifyWithOutsideChatOnChatAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.getNavigation(with: .unknown, notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events.map(\.equatable), [.outside(.chat)])
    }
    
    func test_unknown_shouldNotifyWithWithDetailPaymentAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.getNavigation(with: .unknown, notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.detailPayment)?()
        
        XCTAssertNoDiff(events.map(\.equatable), [.detailPayment(nil)])
    }
    
    // MARK: - sberPay
    
    func test_sberPay_shouldCallMakePaymentsSuccessWithPayload() {
        
        let (url, state) = (anyURL(), makeSberQRConfirmPaymentState())
        let (sut, microServices) = makeSUT()
        
        sut.getNavigation(url: url, state: state)
        
        XCTAssertNoDiff(microServices.makeSberPaymentComplete.payloads.map(\.0), [url])
        XCTAssertNoDiff(microServices.makeSberPaymentComplete.payloads.map(\.1), [state])
    }
    
    func test_sberPay_shouldDeliverPaymentCompleteFailureOnMakeSberPaymentCompleteFailure() {
        
        let error = makeErrorMessage()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .sberPay(anyURL(), makeSberQRConfirmPaymentState()),
            toDeliver: .paymentComplete(.failure(error)),
            on: { microServices.makeSberPaymentComplete.complete(with: error) }
        )
    }
    
    func test_sberPay_shouldDeliverPaymentCompleteSuccessOnMakeSberPaymentCompleteSuccess() {
        
        let complete = makePaymentsComplete()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .sberPay(anyURL(), makeSberQRConfirmPaymentState()),
            toDeliver: .paymentComplete(.success(.init(complete))),
            on: { microServices.makeSberPaymentComplete.complete(with: complete) }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRNavigationComposer
    private typealias MakeInternetTVSpy = Spy<SUT.MicroServices.MakeInternetTVPayload, InternetTVDetailsViewModel, Never>
    private typealias MakeOperatorSearchSpy = Spy<SUT.MicroServices.MakeOperatorSearchPayload, QRNavigation.OperatorSearch, Never>
    private typealias MakePaymentsSpy = Spy<SUT.MicroServices.MakePaymentsPayload, ClosePaymentsViewModelWrapper, Never>
    private typealias MakeProviderPickerSpy = Spy<SUT.MicroServices.MakeProviderPickerPayload, QRNavigation.ProviderPicker, Never>
    private typealias MakeQRFailureSpy = Spy<SUT.MicroServices.MakeQRFailurePayload, QRFailedViewModel, Never>
    private typealias MakeQRFailureWithQRSpy = Spy<SUT.MicroServices.MakeQRFailureWithQRPayload, QRFailedViewModel, Never>
    private typealias MakeSberPaymentCompleteSpy = Spy<SUT.MicroServices.MakeSberPaymentCompletePayload, QRNavigation.PaymentComplete, QRNavigation.ErrorMessage>
    private typealias MakeSberQRSpy = Spy<SUT.MicroServices.MakeSberQRPayload, SberQRConfirmPaymentViewModel, QRNavigation.ErrorMessage>
    private typealias MakeServicePickerSpy = Spy<PaymentProviderServicePickerPayload, SUT.MicroServices.ServicePicker, Never>
    
    private struct MicroServicesSpy {
        
        let makeInternetTV: MakeInternetTVSpy
        let makeOperatorSearch: MakeOperatorSearchSpy
        let makePayments: MakePaymentsSpy
        let makeProviderPicker: MakeProviderPickerSpy
        let makeQRFailure: MakeQRFailureSpy
        let makeQRFailureWithQR: MakeQRFailureWithQRSpy
        let makeSberPaymentComplete: MakeSberPaymentCompleteSpy
        let makeSberQR: MakeSberQRSpy
        let makeServicePicker: MakeServicePickerSpy
        
        var microServices: SUT.MicroServices {
            
            return .init(
                makeInternetTV: makeInternetTV.process,
                makeOperatorSearch: makeOperatorSearch.process,
                makePayments: makePayments.process,
                makeProviderPicker: makeProviderPicker.process,
                makeQRFailure: makeQRFailure.process,
                makeQRFailureWithQR: makeQRFailureWithQR.process,
                makeSberPaymentComplete: makeSberPaymentComplete.process,
                makeSberQR: makeSberQR.process,
                makeServicePicker: makeServicePicker.process
            )
        }
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        microServices: MicroServicesSpy
    ) {
        let microServicesSpy = MicroServicesSpy(
            makeInternetTV: MakeInternetTVSpy(),
            makeOperatorSearch: MakeOperatorSearchSpy(),
            makePayments: MakePaymentsSpy(),
            makeProviderPicker: MakeProviderPickerSpy(),
            makeQRFailure: MakeQRFailureSpy(),
            makeQRFailureWithQR: MakeQRFailureWithQRSpy(),
            makeSberPaymentComplete: MakeSberPaymentCompleteSpy(),
            makeSberQR: MakeSberQRSpy(),
            makeServicePicker: MakeServicePickerSpy()
        )
        let sut = SUT(microServices: microServicesSpy.microServices)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(microServicesSpy.makeInternetTV, file: file, line: line)
        trackForMemoryLeaks(microServicesSpy.makePayments, file: file, line: line)
        trackForMemoryLeaks(microServicesSpy.makeQRFailure, file: file, line: line)
        trackForMemoryLeaks(microServicesSpy.makeQRFailureWithQR, file: file, line: line)
        trackForMemoryLeaks(microServicesSpy.makeProviderPicker, file: file, line: line)
        trackForMemoryLeaks(microServicesSpy.makeOperatorSearch, file: file, line: line)
        trackForMemoryLeaks(microServicesSpy.makeSberQR, file: file, line: line)
        trackForMemoryLeaks(microServicesSpy.makeServicePicker, file: file, line: line)
        
        return (sut, microServicesSpy)
    }
    
    private func makePaymentsModel(
        model: Model = .mockWithEmptyExcept(),
        category: Payments.Category = .fast,
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate
    ) -> ClosePaymentsViewModelWrapper {
        
        return .init(model: model, category: category, scheduler: scheduler)
    }
    
    private func makeQRFailed(
        model: Model = .mockWithEmptyExcept(),
        addCompanyAction: @escaping () -> Void = {},
        requisitsAction: @escaping () -> Void = {}
    ) -> QRFailedViewModel {
        
        return .init(model: model, addCompanyAction: addCompanyAction, requisitsAction: requisitsAction)
    }
    
    private func makeMappedMixed() -> QRModelResult {
        
        return .mapped(.mixed(.init(operators: makeMixedOperators(), qrCode: makeQR(), qrMapping: makeQRMapping())))
    }
    
    private func makeProviderPicker() -> QRNavigation.ProviderPicker {
        
        let (mix, qrCode, qrMapping) = makeMixed()
        return .preview(mix: mix, qrCode: qrCode, qrMapping: qrMapping)
    }
    
    private func makeMultiple(
    ) -> (multiple: MultiElementArray<SegmentedOperatorData>, qrCode: QRCode, qrMapping: QRMapping) {
        
        return (makeMultipleOperators(), makeQR(), makeQRMapping())
    }
    
    private func makeMappedMultiple() -> QRModelResult {
        
        let (multiple, qrCode, qrMapping) = makeMultiple()
        return .mapped(.multiple(multiple, qrCode, qrMapping))
    }
    
    private func makeOperatorSearch() -> QRNavigation.OperatorSearch {
        
        return .init(searchBar: .banks(), navigationBar: .sample, model: .emptyMock, addCompanyAction: {}, requisitesAction: {})
    }
    
    private func makeServicePicker(
    ) -> SUT.MicroServices.ServicePicker {
        
        return .init(
            initialState: .init(
                content: .init(
                    initialState: .init(payload: .preview),
                    reduce: { state, _ in (state, nil) },
                    handleEffect: { _,_ in }
                )
            ),
            factory: .init(
                makeAnywayFlowModel: { _ in fatalError() },
                makePayByInstructionsViewModel: { _ in fatalError() }
            ),
            scheduler: .immediate
        )
    }
    
    private func makeMappedSingle(
        `operator`: SegmentedOperatorData? = nil,
        qrCode: QRCode? = nil,
        qrMapping: QRMapping? = nil
    ) -> QRModelResult {
        
        return .mapped(.single(`operator` ?? makeSegmentedOperatorData(), qrCode ?? makeQR(), qrMapping ?? makeQRMapping()))
    }
    
    private func makeInternetTVModel(
    ) -> InternetTVDetailsViewModel {
        
        return .init(model: .mockWithEmptyExcept(), closeAction: {})
    }
    
    private func makeSberQR(
        initialState: SberQRConfirmPaymentViewModel.State = .init(confirm: .editableAmount(.preview))
    ) -> QRNavigation.SberQR {
        
        return .init(initialState: initialState, reduce: { state, _ in state}, scheduler: .immediate)
    }
    
    private func makePaymentsComplete(
    ) -> QRNavigation.PaymentComplete {
        
        return .init(model: .mockWithEmptyExcept(), sections: [])
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with qrResult: QRModelResult,
        toDeliver expectedResult: QRNavigation.EquatableQRNavigation,
        notify: @escaping SUT.Notify = { _ in },
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, with: .qrResult(qrResult), toDeliver: expectedResult, notify: notify, on: action, file: file, line: line)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with payload: SUT.Payload,
        toDeliver expectedResult: QRNavigation.EquatableQRNavigation,
        notify: @escaping SUT.Notify = { _ in },
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(payload: payload, notify: notify) {
            
            XCTAssertNoDiff($0.equatable, expectedResult, "Expected \(expectedResult), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(
        _ sut: SUT,
        with qrResult: QRModelResult,
        delivers expectedEvent: SUT.NotifyEvent,
        for destinationAction: @escaping (QRNavigation) -> Void,
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedEvent: SUT.NotifyEvent?
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(
            with: qrResult,
            notify: { receivedEvent = $0 }
        ) {
            destinationAction($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedEvent?.equatable, expectedEvent.equatable, "Expected \(expectedEvent), but got \(String(describing: receivedEvent)) instead.", file: file, line: line)
    }
}

private extension ClosePaymentsViewModelWrapper {
    
    func closeAction() {
        
        paymentsViewModel.closeAction()
    }
    
    func scanQRCode() {
        
        paymentsViewModel.action.send(PaymentsViewModelAction.ScanQrCode())
    }
    
    func contactAbroad(source: Payments.Operation.Source) {
        
        let action = PaymentsViewModelAction.ContactAbroad(source: source)
        paymentsViewModel.action.send(action)
    }
}

// MARK: - DSL & Equatable

extension QRNavigation {
    
    // MARK: - payments
    
    var payments: ClosePaymentsViewModelWrapper? {
        
        guard case let .payments(payments) = self
        else { return nil }
        
        return payments.model
    }
    
    // MARK: - providerPicker
    
    var providerPicker: SegmentedPaymentProviderPickerFlowModel? {
        
        guard case let .providerPicker(providerPicker) = self
        else { return nil }
        
        return providerPicker.model
    }
    
    func providerPickerGoTo(
        to goTo: SegmentedPaymentProviderPickerFlowEvent.GoTo
    ) {
        providerPicker?.event(.goTo(goTo))
    }
    
    // MARK: - servicePicker
    
    var servicePicker: AnywayServicePickerFlowModel? {
        
        guard case let .servicePicker(servicePicker) = self
        else { return nil }
        
        return servicePicker.model
    }
}

extension QRNavigationComposer.NotifyEvent {
    
    var equatable: EquatableNotifyEvent {
        
        switch self {
        case let .contactAbroad(contactAbroad):
            return .contactAbroad(contactAbroad)
            
        case let .detailPayment(detailPayment):
            return .detailPayment(detailPayment)
            
        case .dismiss:
            return .dismiss
            
        case let .isLoading(isLoading):
            return .isLoading(isLoading)
            
        case let .outside(outside):
            return .outside(outside)
            
        case let .qrNavigation(qrNavigation):
            return .qrNavigation(qrNavigation.equatable)
            
        case let .sberPay(sberPay):
            return .sberPay(sberPay)
            
        case .scanQR:
            return .scanQR
        }
    }
    
    enum EquatableNotifyEvent: Equatable {
        
        case contactAbroad(Payments.Operation.Source)
        case detailPayment(QRCode?)
        case dismiss
        case isLoading(Bool)
        case outside(QRNavigationComposer.NotifyEvent.Outside)
        case qrNavigation(QRNavigation.EquatableQRNavigation)
        case sberPay(SberQRConfirmPaymentState)
        case scanQR
    }
}

extension QRNavigation {
    
    var equatable: EquatableQRNavigation {
    
        switch self {
        case let .failure(failure):
            return .failure(.init(failure))
            
        case .internetTV:
            return .internetTV
            
        case let .operatorSearch(operatorSearch):
            return .operatorSearch(.init(operatorSearch))
            
        case let .payments(node):
            return .payments(.init(node.model))
            
        case let .paymentComplete(.failure(message)):
            return .paymentComplete(.failure(message))
            
        case let .paymentComplete(.success(paymentComplete)):
            return .paymentComplete(.success(.init(paymentComplete)))
            
        case let .providerPicker(node):
            return .providerPicker(.init(node.model))
            
        case let .sberQR(.failure(message)):
            return .sberQR(.failure(message))
            
        case let .sberQR(.success(sberQR)):
            return .sberQR(.success(.init(sberQR)))
            
        case let .servicePicker(node):
            return .servicePicker(.init(node.model))
        }
    }
    
    enum EquatableQRNavigation: Equatable {
        
        case failure(ObjectIdentifier)
        case internetTV
        case operatorSearch(ObjectIdentifier)
        case payments(ObjectIdentifier)
        case paymentComplete(PaymentCompleteResult)
        case providerPicker(ObjectIdentifier)
        case sberQR(SberQRResult)
        case servicePicker(ObjectIdentifier)
        
        typealias OperatorSearch = QRSearchOperatorViewModel
        typealias PaymentCompleteResult = Result<ObjectIdentifier, ErrorMessage>
        typealias ProviderPicker = SegmentedPaymentProviderPickerFlowModel
        typealias SberQRResult = Result<ObjectIdentifier, QRNavigation.ErrorMessage>
    }
}

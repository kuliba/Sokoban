//
//  PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.10.2024.
//

import Combine
@testable import ForaBank
import XCTest

final class PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallNotify() {
        
        let (_,_,_, spy, _) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_init_shouldNotCallMakeQRModel() {
        
        let (_,_,_,_, makeQRModel) = makeSUT()
        
        XCTAssertEqual(makeQRModel.callCount, 0)
    }
    
    // MARK: - abroad
    
    func test_makeAbroad_shouldDeliverAbroadWithAbroadMode() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        XCTAssertNoDiff(abroad.model.mode, .abroad)
    }
    
    func test_makeAbroad_shouldCallNotifyWithDismissOnPaymentRequest() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        abroad.requestPayment(with: .avtodor)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeAbroad_shouldCallNotifyWithDelayOnPaymentRequestWithSource() throws {
        
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        abroad.requestPayment(with: .avtodor)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(299))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.contacts(.avtodor))
        ])
    }
    
    func test_makeAbroad_shouldCallNotifyWithDelayOnPaymentRequestWithLatest() throws {
        
        let latestID: LatestPaymentData.ID = .random(in: 1...100)
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        abroad.requestPayment(with: .latestPayment(latestID))
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(299))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.latest(latestID))
        ])
    }
    
    func test_makeAbroad_shouldCallNotifyWithDismissOnCountriesItemTap() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        abroad.countriesItemTap(with: .avtodor)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeAbroad_shouldCallNotifyWithDelayOnCountriesItemTapWithSource() throws {
        
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let abroad = nanoServices.makeAbroad(spy.call(payload:))
        
        abroad.countriesItemTap(with: .avtodor)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(299))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.countries(.avtodor))
        ])
    }
    
    // MARK: - makeAnotherCard
    
    func test_makeAnotherCard_shouldRequestTemplatesList() {
        
        let model: Model = .mockWithEmptyExcept()
        let productTemplateListRequestSpy = ValueSpy(model.productTemplateListRequest)
        XCTAssertEqual(productTemplateListRequestSpy.values.count, 0)
        
        let (_, nanoServices, _, spy, _) = makeSUT(model: model)
        _ = nanoServices.makeAnotherCard(spy.call(payload:))
        
        XCTAssertEqual(productTemplateListRequestSpy.values.count, 1)
    }
    
    func test_makeAnotherCard_shouldCallNotifyWithDismissOnScanQR() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        let anotherCard = nanoServices.makeAnotherCard(spy.call(payload:))
        
        anotherCard.scanQR()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeAnotherCard_shouldCallNotifyWithDelayOnScanQR() {
        
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let anotherCard = nanoServices.makeAnotherCard(spy.call(payload:))
        
        anotherCard.scanQR()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(799))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(800))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.qr(.scan))
        ])
    }
    
    func test_makeAnotherCard_shouldCallNotifyWithDelayOnContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let anotherCard = nanoServices.makeAnotherCard(spy.call(payload:))
        
        anotherCard.contactAbroad(source: source)
        
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(699))
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(700))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .select(.contactAbroad(source))
        ])
    }
    
    // MARK: - makeContacts
    
    func test_makeContacts_shouldDeliverContactsWithContactsFastPaymentsMode() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        let contacts = nanoServices.makeContacts(spy.call(payload:))
        
        XCTAssertNoDiff(contacts.model.mode, .fastPayments(.contacts))
    }
    
    func test_makeContacts_shouldCallNotifyWithDismissOnPaymentRequest() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        let contacts = nanoServices.makeContacts(spy.call(payload:))
        
        contacts.requestPayment(with: .avtodor)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeContacts_shouldCallNotifyWithDelayOnPaymentRequestWithSource() throws {
        
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let contacts = nanoServices.makeContacts(spy.call(payload:))
        
        contacts.requestPayment(with: .avtodor)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(299))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.contacts(.avtodor))
        ])
    }
    
    func test_makeContacts_shouldCallNotifyWithDelayOnPaymentRequestWithLatest() throws {
        
        let latestID: LatestPaymentData.ID = .random(in: 1...100)
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let contacts = nanoServices.makeContacts(spy.call(payload:))
        
        contacts.requestPayment(with: .latestPayment(latestID))
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(299))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.latest(latestID))
        ])
    }
    
    func test_makeContacts_shouldCallNotifyWithDismissOnCountriesItemTap() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        let contacts = nanoServices.makeContacts(spy.call(payload:))
        
        contacts.countriesItemTap(with: .avtodor)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeContacts_shouldCallNotifyWithDelayOnCountriesItemTapWithSource() {
        
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let contacts = nanoServices.makeContacts(spy.call(payload:))
        
        contacts.countriesItemTap(with: .avtodor)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(299))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.countries(.avtodor))
        ])
    }
    
    // MARK: - makeDetail
    
    func test_makeDetail_shouldCallNotifyWithDismissOnScanQR() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        let detail = nanoServices.makeDetail(spy.call(payload:))
        
        detail.scanQR()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeDetail_shouldCallNotifyWithDelayOnScanQR() {
        
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let detail = nanoServices.makeDetail(spy.call(payload:))
        
        detail.scanQR()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(799))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(800))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.qr(.scan))
        ])
    }
    
    func test_makeDetail_shouldCallNotifyWithDelayOnContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let detail = nanoServices.makeDetail(spy.call(payload:))
        
        detail.contactAbroad(source: source)
        
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(699))
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(700))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .select(.contactAbroad(source))
        ])
    }
    
    // MARK: - makeLatest
    
    func test_makeLatest_shouldDeliverNilForMissingLatest() {
        
        let latestData = makeLatestPaymentData(type: .internet)
        let model: Model = .mockWithEmptyExcept()
        let (_, nanoServices, _, spy, _) = makeSUT(model: model)
        
        XCTAssertNil(nanoServices.makeLatest(latestData.id, spy.call(payload:)))
        XCTAssertFalse(model.contains(latestData))
    }
    
    func test_makeLatest_shouldDeliverNilForNonEligibleType() {
        
        let latestData = makeLatestPaymentData(type: .unknown)
        let model = makeModel(with: latestData)
        let (_, nanoServices, _, spy, _) = makeSUT(model: model)
        
        XCTAssertNil(nanoServices.makeLatest(latestData.id, spy.call(payload:)))
        XCTAssertTrue(model.contains(latestData))
    }
    
    func test_makeLatest_shouldCallNotifyWithDismissOnScanQR() throws {
        
        let latestData = makeLatestPaymentData(type: .internet)
        let model = makeModel(with: latestData)
        let (_, nanoServices, _, spy, _) = makeSUT(model: model)
        let latest = try XCTUnwrap(nanoServices.makeLatest(latestData.id, spy.call(payload:)))
        
        latest.scanQR()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeLatest_shouldCallNotifyWithDelayOnScanQR() throws {
        
        let latestData = makeLatestPaymentData(type: .internet)
        let model = makeModel(with: latestData)
        let (_, nanoServices, scheduler, spy, _) = makeSUT(model: model)
        let latest = try XCTUnwrap(nanoServices.makeLatest(latestData.id, spy.call(payload:)))
        
        latest.scanQR()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(799))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(800))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.qr(.scan))
        ])
    }
    
    func test_makeLatest_shouldCallNotifyWithDelayOnContactAbroad() throws {
        
        let latestData = makeLatestPaymentData(type: .internet)
        let source: Payments.Operation.Source = .avtodor
        let model = makeModel(with: latestData)
        let (_, nanoServices, scheduler, spy, _) = makeSUT(model: model)
        let latest = try XCTUnwrap(nanoServices.makeLatest(latestData.id, spy.call(payload:)))
        
        latest.contactAbroad(source: source)
        
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(699))
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(700))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .select(.contactAbroad(source))
        ])
    }
    
    // MARK: - makeMeToMe
    
    func test_makeMeToMe_shouldDeliverNilOnMissingProduct() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        
        XCTAssertNil(nanoServices.makeMeToMe(spy.call(payload:)))
    }
    
    func test_makeMeToMe_shouldDeliverMeToMeWithDemandDepositMode() throws {
        
        let model = try makeModelWithMeToMeProduct()
        let (_, nanoServices, _, spy, _) = makeSUT(model: model)
        
        XCTAssertNotNil(nanoServices.makeMeToMe(spy.call(payload:)))
    }
    
    func test_makeMeToMe_shouldDeliverSuccessOnEmitResponseSuccess() throws {
        
        let success: PaymentsSuccessViewModel = .sample1
        let model = try makeModelWithMeToMeProduct()
        let (_, nanoServices, _, spy, _) = makeSUT(model: model)
        let makeMeToMe = try XCTUnwrap(nanoServices.makeMeToMe(spy.call(payload:)))
        
        makeMeToMe.emitResponseSuccess(with: success)
        
        XCTAssertNoDiff(spy.equatablePayloads, [.receive(.successMeToMe(.init(success)))])
    }
    
    func test_makeMeToMe_shouldBindSuccessDismissOnEmitClose() throws {
        
        let success: PaymentsSuccessViewModel = .sample2
        let model = try makeModelWithMeToMeProduct()
        let (_, nanoServices, _, spy, _) = makeSUT(model: model)
        let makeMeToMe = try XCTUnwrap(nanoServices.makeMeToMe(spy.call(payload:)))
        
        makeMeToMe.emitResponseSuccess(with: success)
        success.action.send(PaymentsSuccessAction.Button.Close())
        
        XCTAssertNoDiff(spy.equatablePayloads, [
            .receive(.successMeToMe(.init(success))),
            .dismiss
        ])
    }
    
    func test_makeMeToMe_shouldBindSuccessDismissOnEmitRepeat() throws {
        
        let success: PaymentsSuccessViewModel = .sample2
        let model = try makeModelWithMeToMeProduct()
        let (_, nanoServices, _, spy, _) = makeSUT(model: model)
        let makeMeToMe = try XCTUnwrap(nanoServices.makeMeToMe(spy.call(payload:)))
        
        makeMeToMe.emitResponseSuccess(with: success)
        success.action.send(PaymentsSuccessAction.Button.Repeat())
        
        XCTAssertNoDiff(spy.equatablePayloads, [
            .receive(.successMeToMe(.init(success))),
            .dismiss
        ])
    }
    
    func test_makeMeToMe_shouldDeliverAlertOnEmitResponseFailure() throws {
        
        let model = try makeModelWithMeToMeProduct()
        let (_, nanoServices, _, spy, _) = makeSUT(model: model)
        let makeMeToMe = try XCTUnwrap(nanoServices.makeMeToMe(spy.call(payload:)))
        
        makeMeToMe.emitResponseFailure()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.receive(.alert("Перевод выполнен"))])
    }
    
    func test_makeMeToMe_shouldDeliverDismissOnCloseBottomSheet() throws {
        
        let model = try makeModelWithMeToMeProduct()
        let (_, nanoServices, _, spy, _) = makeSUT(model: model)
        let makeMeToMe = try XCTUnwrap(nanoServices.makeMeToMe(spy.call(payload:)))
        
        makeMeToMe.closeBottomSheet()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    // MARK: - makeScanQR
    
    func test_makeScanQR_shouldCallMakeQRModel() {
        
        let (_, nanoServices, _,_, makeQRModel) = makeSUT()
        
        _ = nanoServices.makeScanQR { _ in }
        
        XCTAssertEqual(makeQRModel.callCount, 1)
    }
    
    func test_makeScanQR_shouldDeliverScanQR() {
        
        let qrModel = makeQRModel()
        let (_, nanoServices, _,_,_) = makeSUT(qrModel: qrModel)
        
        let scanQR = nanoServices.makeScanQR { _ in }
        
        XCTAssert(scanQR.model === qrModel)
    }
    
    func test_makeScanQR_shouldNotCallNotify() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        
        _ = nanoServices.makeScanQR(spy.call(payload:))
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_makeScanQR_shouldCallNotifyWithDelayWithCancelledOnQRCancelled() {
        
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let scanQR = nanoServices.makeScanQR(spy.call(payload:))
        
        scanQR.model.event(.cancel)
        
        scheduler.advance(by: .milliseconds(99))
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(spy.equatablePayloads, [.select(.qr(.cancelled))])
    }
    
    func test_makeScanQR_shouldCallNotifyWithDelayWithInflightOnQRInflight() {
        
        let scanResult = QRViewModel.ScanResult.unknown
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let scanQR = nanoServices.makeScanQR(spy.call(payload:))
        
        scanQR.model.event(.scanResult(scanResult))
        
        scheduler.advance(by: .milliseconds(99))
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(spy.equatablePayloads, [.select(.qr(.inflight))])
    }
    
    func test_makeScanQR_shouldCallNotifyWithDelayWithQRResultOnQRResult() {
        
        let qrResult = QRModelResult.unknown
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let scanQR = nanoServices.makeScanQR(spy.call(payload:))
        
        scanQR.model.event(.qrResult(qrResult))
        
        scheduler.advance(by: .milliseconds(99))
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(1))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .select(.qr(.qrResult(qrResult)))
        ])
    }
    
    // MARK: - makeSource
    
    func test_makeSource_shouldCallNotifyWithDismissOnScanQR() {
        
        let (_, nanoServices, _, spy, _) = makeSUT()
        let source = nanoServices.makeSource(.avtodor, spy.call(payload:))
        
        source.scanQR()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
    }
    
    func test_makeSource_shouldCallNotifyWithDelayOnScanQR() {
        
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let source = nanoServices.makeSource(.avtodor, spy.call(payload:))
        
        source.scanQR()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(799))
        XCTAssertNoDiff(spy.equatablePayloads, [.dismiss])
        
        scheduler.advance(by: .milliseconds(800))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .dismiss,
            .select(.qr(.scan))
        ])
    }
    
    func test_makeSource_shouldCallNotifyWithDelayOnContactAbroad() {
        
        let operationSource: Payments.Operation.Source = .avtodor
        let (_, nanoServices, scheduler, spy, _) = makeSUT()
        let source = nanoServices.makeSource(.avtodor, spy.call(payload:))
        
        source.contactAbroad(source: operationSource)
        
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(699))
        XCTAssertNoDiff(spy.equatablePayloads, [])
        
        scheduler.advance(by: .milliseconds(700))
        XCTAssertNoDiff(spy.equatablePayloads, [
            .select(.contactAbroad(operationSource))
        ])
    }
    
    func test_makeSource_shouldCallNotifyWithAbroadOnDirectSourceOnCloseAction() {
        
        let direct = makeDirectSource()
        let (_, nanoServices, _, spy, _) = makeSUT()
        let source = nanoServices.makeSource(direct, spy.call(payload:))
        
        source.model.closeAction()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.select(.buttonType(.abroad))])
    }
    
    func test_makeSource_shouldCallNotifyWithByPhoneNumberOnSFPSourceOnCloseAction() {
        
        let sfp = makeSFPSource()
        let (_, nanoServices, _, spy, _) = makeSUT()
        let source = nanoServices.makeSource(sfp, spy.call(payload:))
        
        source.model.closeAction()
        
        XCTAssertNoDiff(spy.equatablePayloads, [.select(.buttonType(.byPhoneNumber))])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer
    private typealias NotifySpy = CallSpy<SUT.Event, Void>
    private typealias MakeQRModelSpy = CallSpy<Void, QRModel>
    
    private func makeSUT(
        qrModel: QRModel? = nil,
        model: Model = .mockWithEmptyExcept(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        nanoServices: SUT.NanoServices,
        scheduler: TestSchedulerOfDispatchQueue,
        spy: NotifySpy,
        makeQRModelSpy: MakeQRModelSpy
    ) {
        let makeQRModelSpy = MakeQRModelSpy(stubs: [qrModel ?? makeQRModel()])
        let scheduler = DispatchQueue.test
        let sut = SUT(
            makeQRModel: makeQRModelSpy.call,
            model: model,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = NotifySpy(stubs: .init(repeating: (), count: 9))
        let nanoServices = sut.compose()
        
        //    trackForMemoryLeaks(sut, file: file, line: line)
        //    trackForMemoryLeaks(model, file: file, line: line)
        //    trackForMemoryLeaks(scheduler, file: file, line: line)
        //    trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(makeQRModelSpy, file: file, line: line)
        
        return (sut, nanoServices, scheduler, spy, makeQRModelSpy)
    }
    
    private func makeModel(
        with latestData: LatestPaymentData,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let model: Model = .mockWithEmptyExcept()
        model.latestPayments.value.append(latestData)
        
        XCTAssertTrue(model.contains(latestData), "Expected model with LatestPaymentData \(latestData).", file: file, line: line)
        
        return model
    }
    
    private func makeModelWithMeToMeProduct(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Model {
        
        let model: Model = .mockWithEmptyExcept()
        try model.addMeToMeProduct(file: file, line: line)
        
        return model
    }
    
    private func makeDirectSource(
        phone: String? = nil,
        countryId: CountryData.ID = anyMessage(),
        serviceData: PaymentServiceData? = nil
    ) -> Payments.Operation.Source {
        
        return .direct(phone: phone, countryId: countryId, serviceData: serviceData)
    }
    
    private func makeSFPSource(
        phone: String = anyMessage(),
        bankId: BankData.ID = anyMessage()
    ) -> Payments.Operation.Source {
        
        return .sfp(phone: phone, bankId: bankId)
    }
    
    private func makeQRModel(
        mapScanResult: @escaping (QRViewModel.ScanResult, @escaping (QRModelResult) -> Void) -> Void = { _,_ in },
        makeQRModel: @escaping (@escaping () -> Void) -> QRViewModel = { return .init(closeAction: $0, qrResolve: { _ in .unknown }) },
        scheduler: AnySchedulerOfDispatchQueue = .immediate
    ) -> QRModel {
        
        return .init(
            mapScanResult: mapScanResult,
            makeQRModel: makeQRModel,
            scheduler: scheduler
        )
    }
}

// MARK: - Equatable

private extension PaymentsTransfersPersonalTransfersDomain.FlowEvent {
    
    var equatable: EquatableEvent {
        
        switch self {
        case .dismiss:
            return .dismiss
            
        case let .receive(receive):
            switch receive {
            case let .alert(alert):
                return .receive(.alert(alert))
                
            case let .successMeToMe(successMeToMe):
                return .receive(.successMeToMe(.init(successMeToMe.model)))
                
            default:
                return unimplemented("\(receive) is not used in tests.")
            }
            
        case let .select(select):
            return .select(select)
        }
    }
    
    enum EquatableEvent: Equatable {
        
        case dismiss
        case receive(Receive)
        case select(PaymentsTransfersPersonalTransfersDomain.Element)
        
        enum Receive: Equatable {
            
            case alert(String)
            case successMeToMe(ObjectIdentifier)
        }
    }
}

private extension CallSpy
where Payload == PaymentsTransfersPersonalTransfersDomain.FlowEvent {
    
    typealias EquatablePayload = PaymentsTransfersPersonalTransfersDomain.FlowEvent.EquatableEvent
    
    var equatablePayloads: [EquatablePayload] {
        
        return payloads.map(\.equatable)
    }
}

// MARK: - DSL

private extension Model {
    
    var productTemplateListRequest: AnyPublisher<ModelAction.ProductTemplate.List.Request, Never> {
        
        action
            .compactMap { $0 as? ModelAction.ProductTemplate.List.Request }
            .eraseToAnyPublisher()
    }
    
    func contains(_ latestData: LatestPaymentData) -> Bool {
        
        latestPayments.value.map(\.id).contains(latestData.id)
    }
}

private extension Node where Model == ContactsViewModel {
    
    func requestPayment(
        with source: Payments.Operation.Source
    ) {
        let action = ContactsViewModelAction.PaymentRequested(source: source)
        model.action.send(action)
    }
    
    func countriesItemTap(
        with source: Payments.Operation.Source
    ) {
        let action = ContactsSectionViewModelAction.Countries.ItemDidTapped(source: source)
        model.action.send(action)
    }
}

private extension Node where Model == ClosePaymentsViewModelWrapper {
    
    func scanQR() {
        
        model.paymentsViewModel.scanQR()
    }
    
    func contactAbroad(
        source: Payments.Operation.Source
    ) {
        model.paymentsViewModel.contactAbroad(source: source)
    }
}

private extension Node where Model == PaymentsViewModel {
    
    func scanQR() {
        
        model.scanQR()
    }
    
    func contactAbroad(
        source: Payments.Operation.Source
    ) {
        model.contactAbroad(source: source)
    }
}

private extension PaymentsViewModel {
    
    func scanQR() {
        
        let action = PaymentsViewModelAction.ScanQrCode()
        self.action.send(action)
    }
    
    func contactAbroad(
        source: Payments.Operation.Source
    ) {
        let action = PaymentsViewModelAction.ContactAbroad(source: source)
        self.action.send(action)
    }
}

private extension PaymentsMeToMeViewModel {
    
    func closeBottomSheet() {
        
        let action = PaymentsMeToMeAction.Close.BottomSheet()
        self.action.send(action)
    }
    
    func emitResponseFailure() {
        
        let action = PaymentsMeToMeAction.Response.Failed()
        self.action.send(action)
    }
    
    func emitResponseSuccess(
        with viewModel: PaymentsSuccessViewModel
    ) {
        let action = PaymentsMeToMeAction.Response.Success(viewModel: viewModel)
        self.action.send(action)
    }
}

private extension Node where Model == PaymentsMeToMeViewModel {
    
    func closeBottomSheet() {
        
        model.closeBottomSheet()
    }
    
    func emitResponseFailure() {
        
        model.emitResponseFailure()
    }
    
    func emitResponseSuccess(
        with viewModel: PaymentsSuccessViewModel
    ) {
        model.emitResponseSuccess(with: viewModel)
    }
}

// MARK: - reusable helpers

// TODO: - move to a different place
extension XCTestCase {
    
    func makeLatestPaymentData(
        id: Int = .random(in: 1...1_000),
        date: Date = .init(),
        paymentDate: String = anyMessage(),
        type: LatestPaymentData.Kind = .unknown
    ) -> LatestPaymentData {
        
        return .init(id: id, date: date, paymentDate: paymentDate, type: type)
    }
    
    func makeMeToMe(
        with model: Model = .mockWithEmptyExcept(),
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PaymentsMeToMeViewModel {
        
        try model.addMeToMeProduct(file: file, line: line)
        let meToMe = try XCTUnwrap(PaymentsMeToMeViewModel(model, mode: .demandDeposit), "Expected PaymentsMeToMeViewModel, got nil instead.", file: file, line: line)
        
        return meToMe
    }
}

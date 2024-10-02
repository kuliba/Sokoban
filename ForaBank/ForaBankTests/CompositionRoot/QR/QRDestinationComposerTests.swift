//
//  QRDestinationComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.10.2024.
//

import Combine
import ForaTools

final class QRDestinationComposer {
    
    private let makePayments: MakePayments
    private let makeQRFailure: MakeQRFailure
    private let makeQRFailureWithQR: MakeQRFailureWithQR
    private let makeProviderPicker: MakeProviderPicker
    
    init(
        makePayments: @escaping MakePayments,
        makeQRFailure: @escaping MakeQRFailure,
        makeQRFailureWithQR: @escaping MakeQRFailureWithQR,
        makeProviderPicker: @escaping MakeProviderPicker
    ) {
        self.makePayments = makePayments
        self.makeQRFailure = makeQRFailure
        self.makeQRFailureWithQR = makeQRFailureWithQR
        self.makeProviderPicker = makeProviderPicker
    }
}

extension QRDestinationComposer {
    
    struct Source: Equatable {
        
        let url: URL
        let type: SourceType
        
        enum SourceType: Equatable {
            
            case c2bSubscribe
            case c2b
        }
        
        static func c2bSubscribe(_ url: URL) -> Self {
            
            return .init(url: url, type: .c2bSubscribe)
        }
        
        static func c2b(_ url: URL) -> Self {
            
            return .init(url: url, type: .c2b)
        }
    }
    
    typealias MakePayments = (Source, @escaping (ClosePaymentsViewModelWrapper) -> Void) -> Void
    
    struct MakeQRFailurePayload {
        
        let chatAction: () -> Void
        let makeDetailPayment: () -> Void
    }
    
    typealias MakeQRFailure = (MakeQRFailurePayload, @escaping (QRFailedViewModel) -> Void) -> Void
    
    struct MakeQRFailureWithQRPayload {
        
        let qrCode: QRCode
        let chatAction: () -> Void
        let makeDetailPayment: (QRCode) -> Void
    }
    
    typealias MakeQRFailureWithQR = (MakeQRFailureWithQRPayload, @escaping (QRFailedViewModel) -> Void) -> Void
    
    struct MakeProviderPickerPayload: Equatable {
        
        let mixed: MultiElementArray<SegmentedOperatorProvider>
        let qr: QRCode
        let qrMapping: QRMapping
    }
    
    typealias ProviderPicker = SegmentedPaymentProviderPickerFlowModel
    typealias MakeProviderPicker = (MakeProviderPickerPayload, @escaping (ProviderPicker) -> Void) -> Void
}

extension QRDestinationComposer {
    
    func compose(
        result: QRModelResult,
        notify: @escaping Notify,
        completion: @escaping QRDestinationCompletion
    ) {
        switch result {
        case let .c2bSubscribeURL(url):
            makePayments(.c2bSubscribe(url)) { [weak self] in
                
                guard let self else { return }
                
                completion(.c2bSubscribe(.init(
                    model: $0,
                    cancellables: self.bindPayments($0, with: notify)
                )))
            }
            
        case let .c2bURL(url):
            makePayments(.c2b(url)) { [weak self] in
                
                guard let self else { return }
                
                completion(.c2b(.init(
                    model: $0,
                    cancellables: self.bindPayments($0, with: notify)
                )))
            }
            
        case let .failure(qr):
            let payload = MakeQRFailureWithQRPayload(
                qrCode: qr,
                chatAction: { notify(.outside(.chat)) },
                makeDetailPayment: { notify(.detailPayment($0)) }
            )
            makeQRFailureWithQR(payload) { completion(.failure($0)) }
            
        case let .mapped(mapped):
            switch mapped {
            case .missingINN:
                let payload = MakeQRFailurePayload(
                    chatAction: { notify(.outside(.chat)) },
                    makeDetailPayment: { notify(.detailPayment(nil)) }
                )
                makeQRFailure(payload) { completion(.failure($0)) }
                
            case let .mixed(mixed, qr, qrMapping):
                let payload = MakeProviderPickerPayload(
                    mixed: mixed,
                    qr: qr,
                    qrMapping: qrMapping
                )
                makeProviderPicker(payload) { [weak self] in
                    
                    guard let self else { return }
                    
                    completion(.providerPicker(.init(
                        model: $0,
                        cancellables: self.bindProviderPicker($0, with: notify)
                    )))
                }
                
            default:
                fatalError()
            }
            
        default:
            fatalError()
        }
    }
    
    enum NotifyEvent: Equatable {
        
        case contactAbroad(Payments.Operation.Source)
        case detailPayment(QRCode?)
        case dismiss
        case isLoading(Bool)
        case outside(Outside)
        case scanQR
        
        enum Outside: Equatable {
            
            case chat, main, payments, scanQR
        }
    }
    
    enum QRDestination {
        
        case c2bSubscribe(Node<ClosePaymentsViewModelWrapper>)
        case c2b(Node<ClosePaymentsViewModelWrapper>)
        case failure(QRFailedViewModel)
        case providerPicker(Node<ProviderPicker>)
    }
    
    typealias Notify = (NotifyEvent) -> Void
    typealias QRDestinationCompletion = (QRDestination) -> Void
}

private extension QRDestinationComposer {
    
    func bindPayments(
        _ wrapper: ClosePaymentsViewModelWrapper,
        with notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let close = wrapper.$isClosed
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = wrapper.paymentsViewModel.action
            .compactMap { $0 as? PaymentsViewModelAction.ScanQrCode }
            .sink { _ in notify(.scanQR) }
        
        let contactAbroad = wrapper.paymentsViewModel.action
            .compactMap { $0 as? PaymentsViewModelAction.ContactAbroad }
            .map(\.source)
            .sink { notify(.contactAbroad($0)) }
        
        return [close, scanQR, contactAbroad]
    }
    
    func bindProviderPicker(
        _ picker: ProviderPicker,
        with notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let isLoading = picker.$state.map(\.isLoading)
        let isLoadingFlip = isLoading
            .combineLatest(isLoading.dropFirst())
            .filter { $0 != $1 }
            .map(\.0)
            .sink { notify(.isLoading($0)) }
        
        let outside = picker.$state
            .compactMap(\.notifyOutside)
            .sink { notify(.outside($0)) }
        
        return [isLoadingFlip, outside]
    }
}

private extension SegmentedPaymentProviderPickerFlowState {
    
    var notifyOutside: QRDestinationComposer.NotifyEvent.Outside? {
        
        switch outside {
        case .none:       return .none
        case .addCompany: return .chat
        case .main:       return .main
        case .payments:   return .payments
        case .scanQR:     return .scanQR
        }
    }
}

import CombineSchedulers
@testable import ForaBank
import XCTest

final class QRDestinationComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, makePayments, makeQRFailure, makeQRFailureWithQR, makeProviderPicker) = makeSUT()
        
        XCTAssertEqual(makePayments.callCount, 0)
        XCTAssertEqual(makeQRFailure.callCount, 0)
        XCTAssertEqual(makeQRFailureWithQR.callCount, 0)
        XCTAssertEqual(makeProviderPicker.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - c2bSubscribe
    
    func test_shouldCallMakeC2BSubscribeWithURL() {
        
        let url = anyURL()
        let (sut, makePayments, _,_,_) = makeSUT()
        
        sut.compose(result: .c2bSubscribeURL(url), notify: { _ in }) { _ in }
        
        XCTAssertNoDiff(makePayments.payloads, [.c2bSubscribe(url)])
    }
    
    func test_shouldDeliverC2BSubscribeOnC2BSubscribeURL() {
        
        let (sut, makePayments, _,_,_) = makeSUT()
        
        expect(sut, with: .c2bSubscribeURL(anyURL()), toDeliver: .c2bSubscribe, on: {
            
            makePayments.complete(with: makePaymentsResult())
        })
    }
    
    func test_shouldDeliverDismissEventOnC2BSubscribeClose() {
        
        let (sut, makePayments, _,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bSubscribeURL(anyURL()),
            delivers: .dismiss,
            for: { $0.c2bSubscribeModel?.closeAction() },
            on: { makePayments.complete(with: makePaymentsResult()) }
        )
    }
    
    func test_shouldDeliverScanQREventOnC2BSubscribeScanQRCode() {
        
        let (sut, makePayments, _,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bSubscribeURL(anyURL()),
            delivers: .scanQR,
            for: { $0.c2bSubscribeScanQR() },
            on: { makePayments.complete(with: makePaymentsResult()) }
        )
    }
    
    func test_shouldDeliverContactAbroadEventOnC2BSubscribeContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, makePayments, _,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bSubscribeURL(anyURL()),
            delivers: .contactAbroad(source),
            for: { $0.c2bSubscribeContactAbroad(source: source) },
            on: { makePayments.complete(with: makePaymentsResult()) }
        )
    }
    
    // MARK: - c2b
    
    func test_shouldCallMakeC2BWithURL() {
        
        let url = anyURL()
        let (sut, makePayments, _,_,_) = makeSUT()
        
        sut.compose(result: .c2bURL(url), notify: { _ in }) { _ in }
        
        XCTAssertNoDiff(makePayments.payloads, [.c2b(url)])
    }
    
    func test_shouldDeliverC2BOnC2BURL() {
        
        let (sut, makePayments, _,_,_) = makeSUT()
        
        expect(sut, with: .c2bURL(anyURL()), toDeliver: .c2b, on: {
            
            makePayments.complete(with: makePaymentsResult())
        })
    }
    
    func test_shouldDeliverDismissEventOnC2BClose() {
        
        let (sut, makePayments, _,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bURL(anyURL()),
            delivers: .dismiss,
            for: { $0.c2bModel?.closeAction() },
            on: { makePayments.complete(with: makePaymentsResult()) }
        )
    }
    
    func test_shouldDeliverScanQREventOnC2BScanQRCode() {
        
        let (sut, makePayments, _,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bURL(anyURL()),
            delivers: .scanQR,
            for: { $0.c2bScanQR() },
            on: { makePayments.complete(with: makePaymentsResult()) }
        )
    }
    
    func test_shouldDeliverContactAbroadEventOnC2BContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, makePayments, _,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bURL(anyURL()),
            delivers: .contactAbroad(source),
            for: { $0.c2bContactAbroad(source: source) },
            on: { makePayments.complete(with: makePaymentsResult()) }
        )
    }
    
    // MARK: - failure
    
    func test_shouldCallMakeQRFailureWithQROnFailure() {
        
        let qr = makeQR()
        let (sut, _,_, makeQRFailure, _) = makeSUT()
        
        sut.compose(result: .failure(qr), notify: { _ in }) { _ in }
        
        XCTAssertNoDiff(makeQRFailure.payloads.map(\.qrCode), [qr])
    }
    
    func test_shouldCallMakeQRFailureWithChatActionOnFailure() {
        
        let (sut, _,_, makeQRFailure, _) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .failure(makeQR()), notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.chatAction)?()
        
        XCTAssertNoDiff(events, [.outside(.chat)])
    }
    
    func test_shouldCallMakeQRFailureWithDetailPaymentActionOnFailure() {
        
        let qr = makeQR()
        let (sut, _,_, makeQRFailure, _) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .failure(makeQR()), notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.makeDetailPayment)?(qr)
        
        XCTAssertNoDiff(events, [.detailPayment(qr)])
    }
    
    func test_shouldDeliverFailureOnFailure() {
        
        let (sut, _,_, makeQRFailure, _) = makeSUT()
        
        expect(sut, with: .failure(makeQR()), toDeliver: .failure, on: {
            
            makeQRFailure.complete(with: .success(makeQRFailedViewModel()))
        })
    }
    
    // MARK: - mapped: missingINN
    
    func test_shouldCallMakeQRFailureOnMissingINN() {
        
        let (sut, _, makeQRFailure, _,_) = makeSUT()
        
        sut.compose(result: .mapped(.missingINN), notify: { _ in }) { _ in }
        
        XCTAssertEqual(makeQRFailure.payloads.count, 1)
    }
    
    func test_shouldCallMakeQRFailureWithChatActionOnMissingINN() {
        
        let (sut, _, makeQRFailure, _,_) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .mapped(.missingINN), notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.chatAction)?()
        
        XCTAssertNoDiff(events, [.outside(.chat)])
    }
    
    func test_shouldCallMakeQRFailureWithDetailPaymentActionOnMissingINN() {
        
        let (sut, _, makeQRFailure, _,_) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .mapped(.missingINN), notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.makeDetailPayment)?()
        
        XCTAssertNoDiff(events, [.detailPayment(nil)])
    }
    
    func test_shouldDeliverFailureOnMissingINN() {
        
        let (sut, _, makeQRFailure, _,_) = makeSUT()
        
        expect(sut, with: .mapped(.missingINN), toDeliver: .failure, on: {
            
            makeQRFailure.complete(with: .success(makeQRFailedViewModel()))
        })
    }
    
    // MARK: - mapped: mixed
    
    func test_shouldCallMakeProviderPickerWithPayloadOnMixed() {
        
        let (mixed, qr, qrMapping) = makeMixed()
        let result: QRModelResult = .mapped(.mixed(mixed, qr, qrMapping))
        let (sut, _,_,_, makeProviderPicker) = makeSUT()
        
        sut.compose(result: result, notify: { _ in }, completion: { _ in })
        
        XCTAssertNoDiff(makeProviderPicker.payloads, [
            .init(mixed: mixed, qr: qr, qrMapping: qrMapping)
        ])
    }
    
    func test_shouldDeliverProviderPickerOnMixed() {
        
        let (sut, _,_,_, makeProviderPicker) = makeSUT()
        
        expect(sut, with: makeMappedMixed(), toDeliver: .providerPicker, on: {
            
            makeProviderPicker.complete(with: makeProviderPickerSuccess())
        })
    }
    
#warning("FIXME")
    //    func test_shouldDeliverIsLoadingTrueEventOnProviderPickerEvent() {
    //
    //        let (sut, _,_,_, makeProviderPicker) = makeSUT()
    //
    //        expect(
    //            sut,
    //            result: makeMappedMixed(),
    //            delivers: .isLoading(true),
    //            for: { $0.providerPickerSetIsLoading(to: true) },
    //            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
    //        )
    //    }
    //
    //    func test_shouldDeliverIsLoadingFalseEventOnProviderPickerEvent() {
    //
    //        let (sut, _,_,_, makeProviderPicker) = makeSUT()
    //
    //        expect(
    //            sut,
    //            result: makeMappedMixed(),
    //            delivers: .isLoading(false),
    //            for: { $0.providerPickerSetIsLoading(to: false) },
    //            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
    //        )
    //    }
    
    func test_shouldDeliverOutsideChatEventOnProviderPickerEvent() {
        
        let (sut, _,_,_, makeProviderPicker) = makeSUT()
        
        expect(
            sut,
            result: makeMappedMixed(),
            delivers: .outside(.chat),
            for: { $0.providerPickerGoTo(to: .addCompany) },
            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    func test_shouldDeliverOutsideMainEventOnProviderPickerEvent() {
        
        let (sut, _,_,_, makeProviderPicker) = makeSUT()
        
        expect(
            sut,
            result: makeMappedMixed(),
            delivers: .outside(.main),
            for: { $0.providerPickerGoTo(to: .main) },
            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    func test_shouldDeliverOutsidePaymentsEventOnProviderPickerEvent() {
        
        let (sut, _,_,_, makeProviderPicker) = makeSUT()
        
        expect(
            sut,
            result: makeMappedMixed(),
            delivers: .outside(.payments),
            for: { $0.providerPickerGoTo(to: .payments) },
            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    func test_shouldDeliverOutsideScanQREventOnProviderPickerEvent() {
        
        let (sut, _,_,_, makeProviderPicker) = makeSUT()
        
        expect(
            sut,
            result: makeMappedMixed(),
            delivers: .outside(.scanQR),
            for: { $0.providerPickerGoTo(to: .scanQR) },
            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRDestinationComposer
    private typealias MakePaymentsSpy = Spy<SUT.Source, ClosePaymentsViewModelWrapper, Never>
    private typealias MakeQRFailure = Spy<SUT.MakeQRFailurePayload, QRFailedViewModel, Never>
    private typealias MakeQRFailureWithQR = Spy<SUT.MakeQRFailureWithQRPayload, QRFailedViewModel, Never>
    private typealias MakeProviderPicker = Spy<SUT.MakeProviderPickerPayload, SUT.ProviderPicker, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makePaymentsSpy: MakePaymentsSpy,
        makeQRFailure: MakeQRFailure,
        makeQRFailureWithQR: MakeQRFailureWithQR,
        makeProviderPicker: MakeProviderPicker
    ) {
        let makePaymentsSpy = MakePaymentsSpy()
        let makeQRFailureWithQR = MakeQRFailureWithQR()
        let makeQRFailure = MakeQRFailure()
        let makeProviderPicker = MakeProviderPicker()
        let sut = SUT(
            makePayments: makePaymentsSpy.process(_:completion:),
            makeQRFailure: makeQRFailure.process(_:completion:),
            makeQRFailureWithQR: makeQRFailureWithQR.process(_:completion:),
            makeProviderPicker: makeProviderPicker.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makePaymentsSpy, file: file, line: line)
        trackForMemoryLeaks(makeQRFailure, file: file, line: line)
        trackForMemoryLeaks(makeQRFailureWithQR, file: file, line: line)
        trackForMemoryLeaks(makeProviderPicker, file: file, line: line)
        
        return (sut, makePaymentsSpy, makeQRFailure, makeQRFailureWithQR, makeProviderPicker)
    }
    
    private func makePaymentsModel(
        model: Model = .mockWithEmptyExcept(),
        category: Payments.Category = .fast,
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate
    ) -> ClosePaymentsViewModelWrapper {
        
        return .init(model: model, category: category, scheduler: scheduler)
    }
    
    private func makePaymentsResult(
        model: Model = .mockWithEmptyExcept(),
        category: Payments.Category = .fast,
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate
    ) -> Result<ClosePaymentsViewModelWrapper, Never> {
        
        return .success(makePaymentsModel(
            model: model,
            category: category,
            scheduler: scheduler
        ))
    }
    
    private func makeQR(
        original: String = anyMessage(),
        rawData: [String: String] = [anyMessage(): anyMessage()]
    ) -> QRCode {
        
        return .init(original: original, rawData: rawData)
    }
    
    private func makeQRFailedViewModel(
        model: Model = .mockWithEmptyExcept(),
        addCompanyAction: @escaping () -> Void = {},
        requisitsAction: @escaping () -> Void = {}
    ) -> QRFailedViewModel {
        
        return .init(model: model, addCompanyAction: addCompanyAction, requisitsAction: requisitsAction)
    }
    
    private func makeMixedOperators(
        _ first: SegmentedOperatorProvider? = nil,
        _ second: SegmentedOperatorProvider? = nil,
        _ tail: SegmentedOperatorProvider...
    ) -> MultiElementArray<SegmentedOperatorProvider> {
        
        return .init(first ?? makeSegmentedOperatorProvider(), second ?? makeSegmentedOperatorProvider(), tail)
    }
    
    private func makeSegmentedOperatorProvider(
    ) -> SegmentedOperatorProvider {
        
        return .provider(.init(
            origin: .init(
                id: anyMessage(),
                icon: nil,
                inn: nil,
                title: anyMessage(),
                segment: anyMessage()
            ),
            segment: anyMessage()
        ))
    }
    
    private func makeQRMapping(
        parameters: [QRParameter] = [],
        operators: [QROperator] = []
    ) -> QRMapping {
        
        return .init(parameters: parameters, operators: operators)
    }
    
    private func makeMixed(
    ) -> (mixed: MultiElementArray<SegmentedOperatorProvider>, qr: QRCode, qrMapping: QRMapping) {
        
        return (makeMixedOperators(), makeQR(), makeQRMapping())
    }
    
    private func makeMappedMixed() -> QRModelResult {
        
        return .mapped(.mixed(makeMixedOperators(), makeQR(), makeQRMapping()))
    }
    
    private func makeProviderPicker() -> SUT.ProviderPicker {
        
        let (mix, qrCode, qrMapping) = makeMixed()
        return .preview(mix: mix, qrCode: qrCode, qrMapping: qrMapping)
    }
    
    private func makeProviderPickerSuccess(
    ) -> Result<SUT.ProviderPicker, Never> {
        
        return .success(makeProviderPicker())
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with payload: QRModelResult,
        toDeliver expectedResult: EquatableQRDestination,
        notify: @escaping SUT.Notify = { _ in },
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.compose(result: payload, notify: notify) {
            
            XCTAssertNoDiff($0.equatable, expectedResult, "Expected \(expectedResult), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(
        _ sut: SUT,
        result: QRModelResult,
        delivers expectedEvent: SUT.NotifyEvent,
        for destinationAction: @escaping (SUT.QRDestination) -> Void,
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedEvent: SUT.NotifyEvent?
        let exp = expectation(description: "wait for completion")
        
        sut.compose(
            result: result,
            notify: { receivedEvent = $0 }
        ) {
            destinationAction($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(receivedEvent, expectedEvent, "Expected \(expectedEvent), but got \(String(describing: receivedEvent)) instead.", file: file, line: line)
    }
}

private extension QRDestinationComposer.QRDestination {
    
    // MARK: - c2bSubscribe
    
    var c2bSubscribe: ClosePaymentsViewModelWrapper? {
        
        guard case let .c2bSubscribe(c2bSubscribe) = self
        else { return nil }
        
        return c2bSubscribe.model
    }
    
    var c2bSubscribeModel: PaymentsViewModel? {
        
        return c2bSubscribe?.paymentsViewModel
    }
    
    func c2bSubscribeScanQR() {
        
        c2bSubscribeModel?.action.send(PaymentsViewModelAction.ScanQrCode())
    }
    
    func c2bSubscribeContactAbroad(source: Payments.Operation.Source) {
        
        let action = PaymentsViewModelAction.ContactAbroad(source: source)
        c2bSubscribeModel?.action.send(action)
    }
    
    // MARK: - c2b
    
    var c2b: ClosePaymentsViewModelWrapper? {
        
        guard case let .c2b(c2b) = self
        else { return nil }
        
        return c2b.model
    }
    
    var c2bModel: PaymentsViewModel? {
        
        return c2b?.paymentsViewModel
    }
    
    func c2bScanQR() {
        
        c2bModel?.action.send(PaymentsViewModelAction.ScanQrCode())
    }
    
    func c2bContactAbroad(source: Payments.Operation.Source) {
        
        let action = PaymentsViewModelAction.ContactAbroad(source: source)
        c2bModel?.action.send(action)
    }
    
    // MARK: - providerPicker
    
    var providerPicker: SegmentedPaymentProviderPickerFlowModel? {
        
        guard case let .providerPicker(providerPicker) = self
        else { return nil }
        
        return providerPicker.model
    }
    
    func providerPickerSetIsLoading(to isLoading: Bool) {
        
        providerPicker?.event(.isLoading(isLoading))
    }
    
    func providerPickerGoTo(
        to goTo: SegmentedPaymentProviderPickerFlowEvent.GoTo
    ) {
        providerPicker?.event(.goTo(goTo))
    }
    
    // MARK: - equatable
    
    var equatable: EquatableQRDestination {
        
        switch self {
        case .c2bSubscribe:   return .c2bSubscribe
        case .c2b:            return .c2b
        case .failure:        return .failure
        case .providerPicker: return .providerPicker
        }
    }
}

private enum EquatableQRDestination: Equatable {
    
    case c2bSubscribe
    case c2b
    case failure
    case providerPicker
}

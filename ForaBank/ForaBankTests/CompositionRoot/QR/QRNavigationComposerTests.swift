//
//  QRNavigationComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.10.2024.
//

import Combine
import ForaTools
import SberQR

enum QRNavigation {
    
    case failure(QRFailedViewModel)
    case internetTV(InternetTVDetailsViewModel)
    case operatorSearch(OperatorSearch)
    case payments(Node<ClosePaymentsViewModelWrapper>)
    case paymentComplete(PaymentCompleteResult)
    case providerPicker(Node<ProviderPicker>)
    case sberQR(SberQRResult)
    case servicePicker(Node<AnywayServicePickerFlowModel>)
    
    typealias OperatorSearch = QRSearchOperatorViewModel
    typealias PaymentCompleteResult = Result<PaymentComplete, ErrorMessage>
    typealias ProviderPicker = SegmentedPaymentProviderPickerFlowModel
    typealias SberQRResult = Result<SberQR, ErrorMessage>
    
    typealias PaymentComplete = PaymentsSuccessViewModel
    typealias SberQR = SberQRConfirmPaymentViewModel
    
    struct ErrorMessage: Error, Equatable {
        
        let title: String
        let message: String
    }
}

struct QRNavigationComposerMicroServices {
    
    let makeInternetTV: MakeInternetTV
    let makePayments: MakePayments
    let makeQRFailure: MakeQRFailure
    let makeQRFailureWithQR: MakeQRFailureWithQR
    let makePaymentComplete: MakePaymentComplete
    let makeProviderPicker: MakeProviderPicker
    let makeOperatorSearch: MakeOperatorSearch
    let makeSberQR: MakeSberQR
    let makeServicePicker: MakeServicePicker
}

extension QRNavigationComposerMicroServices {
    
    typealias MakeInternetTV = ((QRCode, QRMapping), @escaping (InternetTVDetailsViewModel) -> Void) -> Void
    
    enum MakePaymentsPayload: Equatable {
        
        case operationSource(Payments.Operation.Source)
        case qrCode(QRCode)
        case source(Source)
        
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
    }
    
    typealias MakePayments = (MakePaymentsPayload, @escaping (ClosePaymentsViewModelWrapper) -> Void) -> Void
    
    struct MakeQRFailurePayload {
        
        let chat: () -> Void
        let detailPayment: () -> Void
    }
    
    typealias MakeQRFailure = (MakeQRFailurePayload, @escaping (QRFailedViewModel) -> Void) -> Void
    
    struct MakeQRFailureWithQRPayload {
        
        let qrCode: QRCode
        let chat: () -> Void
        let detailPayment: (QRCode) -> Void
    }
    
    typealias MakeQRFailureWithQR = (MakeQRFailureWithQRPayload, @escaping (QRFailedViewModel) -> Void) -> Void
    
    typealias MakePaymentComplete = ((URL, SberQRConfirmPaymentState), @escaping (Result<QRNavigation.PaymentComplete, QRNavigation.ErrorMessage>) -> Void) -> Void
    
    struct MakeProviderPickerPayload: Equatable {
        
        let mixed: MultiElementArray<SegmentedOperatorProvider>
        let qrCode: QRCode
        let qrMapping: QRMapping
    }
    
    typealias MakeProviderPicker = (MakeProviderPickerPayload, @escaping (QRNavigation.ProviderPicker) -> Void) -> Void
    
    struct MakeOperatorSearchPayload: Equatable {
        
        let multiple: MultiElementArray<SegmentedOperatorData>
        let qrCode: QRCode
        let qrMapping: QRMapping
    }
    
    typealias MakeOperatorSearch = (MakeOperatorSearchPayload, @escaping (QRNavigation.OperatorSearch) -> Void) -> Void
    
    typealias SberPay = (SberQRConfirmPaymentState) -> Void
    typealias MakeSberQRPayload = (URL, SberPay)
    typealias MakeSberQR = (MakeSberQRPayload, @escaping (Result<QRNavigation.SberQR, QRNavigation.ErrorMessage>) -> Void) -> Void
    
    typealias ServicePicker = AnywayServicePickerFlowModel
    typealias MakeServicePicker = (PaymentProviderServicePickerPayload, @escaping (ServicePicker) -> Void) -> Void
}

final class QRNavigationComposer {
    
    private let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    typealias MicroServices = QRNavigationComposerMicroServices
}

extension QRNavigationComposer {
    
    func compose(
        payload: Payload,
        notify: @escaping Notify,
        completion: @escaping QRNavigationCompletion
    ) {
        switch payload {
        case let .qrResult(result):
            handle(result: result, with: notify, and: completion)
            
        case let .sberPay(url, state):
            microServices.makePaymentComplete((url, state)) {
                completion(.paymentComplete($0))
            }
        }
    }
    
    enum Payload: Equatable {
        
        case qrResult(QRModelResult)
        case sberPay(URL, SberQRConfirmPaymentState)
    }
    
    enum NotifyEvent: Equatable {
        
        case contactAbroad(Payments.Operation.Source)
        case detailPayment(QRCode?)
        case dismiss
        case isLoading(Bool)
        case outside(Outside)
        case sberPay(SberQRConfirmPaymentState)
        case scanQR
        
        enum Outside: Equatable {
            
            case chat, main, payments, scanQR
        }
    }
    
    typealias Notify = (NotifyEvent) -> Void
    
    typealias QRNavigationCompletion = (QRNavigation) -> Void
}

private extension QRNavigationComposer {
    
    func handle(
        result: QRModelResult,
        with notify: @escaping Notify,
        and completion: @escaping QRNavigationCompletion
    ) {
        switch result {
        case let .c2bSubscribeURL(url):
            handle(.source(.c2bSubscribe(url)), with: notify, and: completion)
            
        case let .c2bURL(url):
            handle(.source(.c2b(url)), with: notify, and: completion)
            
        case let .failure(qrCode):
            let payload = MicroServices.MakeQRFailureWithQRPayload(
                qrCode: qrCode,
                chat: { notify(.outside(.chat)) },
                detailPayment: { notify(.detailPayment($0)) }
            )
            microServices.makeQRFailureWithQR(payload) { completion(.failure($0)) }
            
        case let .mapped(mapped):
            handle(mapped: mapped, with: notify, and: completion)
            
        case let .sberQR(url):
            microServices.makeSberQR((url, { notify(.sberPay($0)) })) {
                
                switch $0 {
                case let .failure(error):
                    completion(.sberQR(.failure(error)))
                    
                case let .success(sberQR):
                    completion(.sberQR(.success(sberQR)))
                }
            }
            
        case .url(_):
            makeQRFailure(with: notify) { completion(.failure($0)) }
            
        case .unknown:
            makeQRFailure(with: notify) { completion(.failure($0)) }
        }
    }
    
    func handle(
        mapped: QRModelResult.Mapped,
        with notify: @escaping Notify,
        and completion: @escaping QRNavigationCompletion
    ) {
        switch mapped {
        case .missingINN:
            makeQRFailure(with: notify) { completion(.failure($0)) }
            
        case let .mixed(mixed, qrCode, qrMapping):
            let payload = MicroServices.MakeProviderPickerPayload(
                mixed: mixed,
                qrCode: qrCode,
                qrMapping: qrMapping
            )
            microServices.makeProviderPicker(payload) { [weak self] in
                
                guard let self else { return }
                
                completion(.providerPicker(.init(
                    model: $0,
                    cancellables: self.bind($0, with: notify)
                )))
            }
            
        case let .multiple(multiple, qrCode, qrMapping):
            let payload = MicroServices.MakeOperatorSearchPayload(
                multiple: multiple,
                qrCode: qrCode,
                qrMapping: qrMapping
            )
            microServices.makeOperatorSearch(payload) { completion(.operatorSearch($0)) }
            
        case let .none(qrCode):
            handle(.qrCode(qrCode), with: notify, and: completion)
            
        case let .provider(payload):
            microServices.makeServicePicker(payload) { [weak self] in
                
                guard let self else { return }
                
                completion(.servicePicker(.init(
                    model: $0,
                    cancellables: self.bind($0, with: notify)
                )))
            }
            
        case let .single(_, qrCode, qrMapping):
            microServices.makeInternetTV((qrCode, qrMapping)) { completion(.internetTV($0)) }
            
        case let .source(source):
            handle(.operationSource(source), with: notify, and: completion)
        }
    }
    
    func handle(
        _ payload: MicroServices.MakePaymentsPayload,
        with notify: @escaping Notify,
        and completion: @escaping (QRNavigation) -> Void
    ) {
        microServices.makePayments(payload) { [weak self] in
            
            guard let self else { return }
            
            completion(.payments(.init(
                model: $0,
                cancellables: self.bind($0, with: notify)
            )))
        }
    }
    
    func makeQRFailure(
        with notify: @escaping Notify,
        completion: @escaping (QRFailedViewModel) -> Void
    ) {
        let payload = MicroServices.MakeQRFailurePayload(
            chat: { notify(.outside(.chat)) },
            detailPayment: { notify(.detailPayment(nil)) }
        )
        microServices.makeQRFailure(payload) { completion($0) }
    }
    
    func bind(
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
    
    func bind(
        _ picker: QRNavigation.ProviderPicker,
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
    
    func bind(
        _ flow: AnywayServicePickerFlowModel,
        with notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let isLoading = flow.$state.map(\.isLoading)
        let isLoadingFlip = isLoading
            .combineLatest(isLoading.dropFirst())
            .filter { $0 != $1 }
            .map(\.0)
            .sink { notify(.isLoading($0)) }
        
        let outside = flow.$state
            .compactMap(\.notifyOutside)
            .sink { notify(.outside($0)) }
        
        return [isLoadingFlip, outside]
    }
}

private extension SegmentedPaymentProviderPickerFlowState {
    
    var notifyOutside: QRNavigationComposer.NotifyEvent.Outside? {
        
        switch outside {
        case .none:       return .none
        case .addCompany: return .chat
        case .main:       return .main
        case .payments:   return .payments
        case .scanQR:     return .scanQR
        }
    }
}

private extension AnywayServicePickerFlowState {
    
    var notifyOutside: QRNavigationComposer.NotifyEvent.Outside? {
        
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

final class QRNavigationComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, microServices) = makeSUT()
        
        XCTAssertEqual(microServices.makeInternetTV.callCount, 0)
        XCTAssertEqual(microServices.makePayments.callCount, 0)
        XCTAssertEqual(microServices.makeQRFailure.callCount, 0)
        XCTAssertEqual(microServices.makeQRFailureWithQR.callCount, 0)
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
        
        sut.compose(with: .c2bSubscribeURL(url))
        
        XCTAssertNoDiff(microServices.makePayments.payloads, [.source(.c2bSubscribe(url))])
    }
    
    func test_c2bSubscribe_shouldDeliverPayments() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bSubscribeURL(anyURL()),
            toDeliver: .payments,
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_c2bSubscribe_shouldDeliverDismissEventOnC2BSubscribeClose() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bSubscribeURL(anyURL()),
            delivers: .dismiss,
            for: { $0.payments?.closeAction() },
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_c2bSubscribe_shouldDeliverScanQREventOnC2BSubscribeScanQRCode() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bSubscribeURL(anyURL()),
            delivers: .scanQR,
            for: { $0.payments?.scanQRCode() },
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
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
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    // MARK: - qrResult: c2b
    
    func test_c2b_shouldCallMakeC2BWithURL() {
        
        let url = anyURL()
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: .c2bURL(url))
        
        XCTAssertNoDiff(microServices.makePayments.payloads, [.source(.c2b(url))])
    }
    
    func test_c2b_shouldDeliverPayments() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bURL(anyURL()),
            toDeliver: .payments,
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_c2b_shouldDeliverDismissEventOnC2BClose() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bURL(anyURL()),
            delivers: .dismiss,
            for: { $0.payments?.closeAction() },
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_c2b_shouldDeliverScanQREventOnC2BScanQRCode() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .c2bURL(anyURL()),
            delivers: .scanQR,
            for: { $0.payments?.scanQRCode() },
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
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
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    // MARK: - qrResult: failure
    
    func test_failure_shouldCallMakeQRFailureWithQR() {
        
        let qrCode = makeQR()
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: .failure(qrCode))
        
        XCTAssertNoDiff(microServices.makeQRFailureWithQR.payloads.map(\.qrCode), [qrCode])
    }
    
    func test_failure_shouldDeliverFailure() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .failure(makeQR()),
            toDeliver: .failure,
            on: { microServices.makeQRFailureWithQR.complete(with: .success(makeQRFailed())) }
        )
    }
    
    func test_failure_shouldDeliverOutsideChatEventOnFailureChatAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(with: .failure(makeQR()), notify: { events.append($0) })
        microServices.makeQRFailureWithQR.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events, [.outside(.chat)])
    }
    
    func test_failure_shouldDeliverDetailPaymentEventOnFailureDetailPaymentAction() {
        
        let qrCode = makeQR()
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(with: .failure(makeQR()), notify: { events.append($0) })
        microServices.makeQRFailureWithQR.payloads.first.map(\.detailPayment)?(qrCode)
        
        XCTAssertNoDiff(events, [.detailPayment(qrCode)])
    }
    
    // MARK: - qrResult: mapped: missingINN
    
    func test_missingINN_shouldCallMakeQRFailure() {
        
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: .mapped(.missingINN))
        
        XCTAssertEqual(microServices.makeQRFailure.payloads.count, 1)
    }
    
    func test_missingINN_shouldDeliverFailureOnMissingINN() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.missingINN),
            toDeliver: .failure,
            on: { microServices.makeQRFailure.complete(with: .success(makeQRFailed())) }
        )
    }
    
    func test_missingINN_shouldDeliverOutsideChatEventOnFailureChatAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(with: .mapped(.missingINN), notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events, [.outside(.chat)])
    }
    
    func test_missingINN_shouldDeliverDetailPaymentEventOnFailureDetailPaymentAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(with: .mapped(.missingINN), notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.detailPayment)?()
        
        XCTAssertNoDiff(events, [.detailPayment(nil)])
    }
    
    // MARK: - qrResult: mapped: mixed
    
    func test_mapped_mixed_shouldCallMakeProviderPickerWithPayload() {
        
        let (mixed, qrCode, qrMapping) = makeMixed()
        let result: QRModelResult = .mapped(.mixed(mixed, qrCode, qrMapping))
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: result)
        
        XCTAssertNoDiff(microServices.makeProviderPicker.payloads, [
            .init(mixed: mixed, qrCode: qrCode, qrMapping: qrMapping)
        ])
    }
    
    func test_mapped_mixed_shouldDeliverProviderPicker() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMixed(),
            toDeliver: .providerPicker,
            on: { microServices.makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
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
    //            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
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
    //            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
    //        )
    //    }
    
    func test_mapped_mixed_shouldDeliverOutsideChatEventOnProviderPickerEvent() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMixed(),
            delivers: .outside(.chat),
            for: { $0.providerPickerGoTo(to: .addCompany) },
            on: { microServices.makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    func test_mapped_mixed_shouldDeliverOutsideMainEventOnProviderPickerEvent() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMixed(),
            delivers: .outside(.main),
            for: { $0.providerPickerGoTo(to: .main) },
            on: { microServices.makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    func test_mapped_mixed_shouldDeliverOutsidePaymentsEventOnProviderPickerEvent() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMixed(),
            delivers: .outside(.payments),
            for: { $0.providerPickerGoTo(to: .payments) },
            on: { microServices.makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    func test_mapped_mixed_shouldDeliverOutsideScanQREventOnProviderPickerEvent() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMixed(),
            delivers: .outside(.scanQR),
            for: { $0.providerPickerGoTo(to: .scanQR) },
            on: { microServices.makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    // MARK: - qrResult: mapped: multiple
    
    func test_mapped_multiple_shouldCallMakeOperatorSearchWithPayload() {
        
        let (multiple, qrCode, qrMapping) = makeMultiple()
        let result: QRModelResult = .mapped(.multiple(multiple, qrCode, qrMapping))
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: result)
        
        XCTAssertNoDiff(microServices.makeOperatorSearch.payloads, [
            .init(multiple: multiple, qrCode: qrCode, qrMapping: qrMapping)
        ])
    }
    
    func test_mapped_multiple_shouldDeliverOperatorSearch() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: makeMappedMultiple(),
            toDeliver: .operatorSearch,
            on: { microServices.makeOperatorSearch.complete(with: makeOperatorSearchSuccess()) }
        )
    }
    
    // TODO: add tests for wrapper as in c2bSubscribe
    
    // MARK: - qrResult: mapped: none
    
    func test_mapped_none_shouldCallMakeDetailPaymentsWithQR() {
        
        let qrCode = makeQR()
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: .mapped(.none(qrCode)))
        
        XCTAssertNoDiff(microServices.makePayments.payloads, [.qrCode(qrCode)])
    }
    
    func test_mapped_none_shouldDeliverPayments() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.none(makeQR())),
            toDeliver: .payments,
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_mapped_none_shouldDeliverDismissEventOnDetailPaymentsClose() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.none(makeQR())),
            delivers: .dismiss,
            for: { $0.payments?.closeAction() },
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_mapped_none_shouldDeliverScanQREventOnDetailPaymentsScanQRCode() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.none(makeQR())),
            delivers: .scanQR,
            for: { $0.payments?.scanQRCode() },
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
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
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    // MARK: - qrResult: mapped: provider
    
    func test_mapped_provider_shouldCallMakeServicePickerWithPayload() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: .mapped(.provider(payload)))
        
        XCTAssertNoDiff(microServices.makeServicePicker.payloads, [payload])
    }
    
    func test_mapped_provider_shouldDeliverServicePicker() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.provider(payload)),
            toDeliver: .servicePicker,
            on: { microServices.makeServicePicker.complete(with: makeServicePickerSuccess()) }
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
    //            on: { microServices.makeServicePicker.complete(with: makeServicePickerSuccess()) }
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
    //            on: { microServices.makeServicePicker.complete(with: makeServicePickerSuccess()) }
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
            on: { microServices.makeServicePicker.complete(with: makeServicePickerSuccess()) }
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
            on: { microServices.makeServicePicker.complete(with: makeServicePickerSuccess()) }
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
            on: { microServices.makeServicePicker.complete(with: makeServicePickerSuccess()) }
        )
    }
    
    func test_mapped_provider_shouldDeliverOutsideScanQREventOnServicePickerEvent() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.provider(payload)),
            delivers: .outside(.scanQR),
            for: { $0.servicePicker?.event(.goTo(.scanQR)) },
            on: { microServices.makeServicePicker.complete(with: makeServicePickerSuccess()) }
        )
    }
    
    // MARK: - qrResult: mapped: single
    
    func test_mapped_single_shouldCallMakeInternetTVWithPayload() {
        
        let (qrCode, qrMapping) = (makeQR(), makeQRMapping())
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: .mapped(.single(
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
            on: { microServices.makeInternetTV.complete(with: makeInternetTVSuccess()) }
        )
    }
    
    // MARK: - qrResult: mapped: source
    
    func test_mapped_source_shouldCallMakeSourcePaymentsWithPayload() {
        
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: .mapped(.source(.avtodor)))
        
        XCTAssertNoDiff(microServices.makePayments.payloads, [.operationSource(.avtodor)])
    }
    
    func test_mapped_source_shouldDeliverPayments() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.source(.avtodor)),
            toDeliver: .payments,
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_mapped_source_shouldDeliverDismissEventOnSourcePaymentsClose() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.source(.avtodor)),
            delivers: .dismiss,
            for: { $0.payments?.closeAction() },
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_mapped_source_shouldDeliverScanQREventOnSourcePaymentsScanQRCode() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .mapped(.source(.avtodor)),
            delivers: .scanQR,
            for: { $0.payments?.scanQRCode() },
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
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
            on: { microServices.makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    // MARK: - qrResult: sberQR
    
    func test_sberQR_shouldCallMakeSberQRWithURLInPayload() {
        
        let url = anyURL()
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: .sberQR(url))
        
        XCTAssertEqual(microServices.makeSberQR.payloads.map(\.0), [url])
    }
    
    func test_sberQR_shouldCallMakeSberQRWithNotifyInPayload() {
        
        let sberState = makeSberQRConfirmPaymentState()
        let (sut, microServices) = makeSUT()
        var receivedEvents = [SUT.NotifyEvent]()
        
        sut.compose(
            with: .sberQR(anyURL()),
            notify: { receivedEvents.append($0) }
        )
        microServices.makeSberQR.payloads.map(\.1).first?(sberState)
        
        XCTAssertNoDiff(receivedEvents, [.sberPay(sberState)])
    }
    
    func test_sberQR_shouldDeliverSberQRFailureOnMakeSberQRFailure() {
        
        let error = makeErrorMessage()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .sberQR(anyURL()),
            toDeliver: .sberQR(.failure(error)),
            on: { microServices.makeSberQR.complete(with: .failure(error)) }
        )
    }
    
    func test_sberQR_shouldDeliverSberQROnMakeSberQRSuccess() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .sberQR(anyURL()),
            toDeliver: .sberQR(.success),
            on: { microServices.makeSberQR.complete(with: .success(self.makeSberQR())) }
        )
    }
    
    // TODO: - add tests for associated type of `sberQR` case, otherwise nothing support the need of `SberQRConfirmPaymentViewModel`
    
    // MARK: - qrResult: url
    
    func test_url_shouldCallMakeQRFailure() {
        
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: .url(anyURL()))
        
        XCTAssertEqual(microServices.makeQRFailure.payloads.count, 1)
    }
    
    func test_url_shouldDeliverFailure() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .url(anyURL()),
            toDeliver: .failure,
            on: { microServices.makeQRFailure.complete(with: .success(makeQRFailed())) }
        )
    }
    
    func test_url_shouldNotifyWithOutsideChatOnChatAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(with: .url(anyURL()), notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events, [.outside(.chat)])
    }
    
    func test_url_shouldNotifyWithWithDetailPaymentAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(with: .url(anyURL()), notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.detailPayment)?()
        
        XCTAssertNoDiff(events, [.detailPayment(nil)])
    }
    
    // MARK: - qrResult: unknown
    
    func test_unknown_shouldCallMakeQRFailure() {
        
        let (sut, microServices) = makeSUT()
        
        sut.compose(with: .unknown)
        
        XCTAssertEqual(microServices.makeQRFailure.payloads.count, 1)
    }
    
    func test_unknown_shouldDeliverFailure() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .unknown,
            toDeliver: .failure,
            on: { microServices.makeQRFailure.complete(with: .success(makeQRFailed())) }
        )
    }
    
    func test_unknown_shouldNotifyWithOutsideChatOnChatAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(with: .unknown, notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events, [.outside(.chat)])
    }
    
    func test_unknown_shouldNotifyWithWithDetailPaymentAction() {
        
        let (sut, microServices) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(with: .unknown, notify: { events.append($0) })
        microServices.makeQRFailure.payloads.first.map(\.detailPayment)?()
        
        XCTAssertNoDiff(events, [.detailPayment(nil)])
    }
    
    // MARK: - sberPay
    
    func test_sberPay_shouldCallMakePaymentsSuccessWithPayload() {
        
        let (url, state) = (anyURL(), makeSberQRConfirmPaymentState())
        let (sut, microServices) = makeSUT()
        
        sut.compose(url: url, state: state)
        
        XCTAssertNoDiff(microServices.makePaymentComplete.payloads.map(\.0), [url])
        XCTAssertNoDiff(microServices.makePaymentComplete.payloads.map(\.1), [state])
    }
    
    func test_sberPay_shouldDeliverPaymentCompleteFailureOnMakePaymentCompleteFailure() {
        
        let error = makeErrorMessage()
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .sberPay(anyURL(), makeSberQRConfirmPaymentState()),
            toDeliver: .paymentComplete(.failure(error)),
            on: { microServices.makePaymentComplete.complete(with: .failure(error)) }
        )
    }
    
    func test_sberPay_shouldDeliverPaymentCompleteSuccessOnMakePaymentCompleteSuccess() {
        
        let (sut, microServices) = makeSUT()
        
        expect(
            sut,
            with: .sberPay(anyURL(), makeSberQRConfirmPaymentState()),
            toDeliver: .paymentComplete(.success),
            on: { microServices.makePaymentComplete.complete(with: .success(self.makePaymentsComplete())) }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRNavigationComposer
    private typealias MakeInternetTVSpy = Spy<(QRCode, QRMapping), InternetTVDetailsViewModel, Never>
    private typealias MakePaymentsSpy = Spy<SUT.MicroServices.MakePaymentsPayload, ClosePaymentsViewModelWrapper, Never>
    private typealias MakeQRFailureSpy = Spy<SUT.MicroServices.MakeQRFailurePayload, QRFailedViewModel, Never>
    private typealias MakeQRFailureWithQRSpy = Spy<SUT.MicroServices.MakeQRFailureWithQRPayload, QRFailedViewModel, Never>
    private typealias MakePaymentCompleteSpy = Spy<(URL, SberQRConfirmPaymentState), QRNavigation.PaymentCompleteResult, Never>
    private typealias MakeProviderPickerSpy = Spy<SUT.MicroServices.MakeProviderPickerPayload, QRNavigation.ProviderPicker, Never>
    private typealias MakeOperatorSearchSpy = Spy<SUT.MicroServices.MakeOperatorSearchPayload, QRNavigation.OperatorSearch, Never>
    private typealias MakeSberQRSpy = Spy<SUT.MicroServices.MakeSberQRPayload, SberQRConfirmPaymentViewModel, QRNavigation.ErrorMessage>
    private typealias MakeServicePickerSpy = Spy<PaymentProviderServicePickerPayload, SUT.MicroServices.ServicePicker, Never>
    
    private struct MicroServicesSpy {
        
        let makeInternetTV: MakeInternetTVSpy
        let makePayments: MakePaymentsSpy
        let makeQRFailure: MakeQRFailureSpy
        let makeQRFailureWithQR: MakeQRFailureWithQRSpy
        let makePaymentComplete: MakePaymentCompleteSpy
        let makeProviderPicker: MakeProviderPickerSpy
        let makeOperatorSearch: MakeOperatorSearchSpy
        let makeSberQR: MakeSberQRSpy
        let makeServicePicker: MakeServicePickerSpy
        
        var microServices: SUT.MicroServices {
            
            return .init(
                makeInternetTV: makeInternetTV.process,
                makePayments: makePayments.process,
                makeQRFailure: makeQRFailure.process,
                makeQRFailureWithQR: makeQRFailureWithQR.process,
                makePaymentComplete: makePaymentComplete.process,
                makeProviderPicker: makeProviderPicker.process,
                makeOperatorSearch: makeOperatorSearch.process,
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
            makePayments: MakePaymentsSpy(),
            makeQRFailure: MakeQRFailureSpy(),
            makeQRFailureWithQR: MakeQRFailureWithQRSpy(),
            makePaymentComplete: MakePaymentCompleteSpy(),
            makeProviderPicker: MakeProviderPickerSpy(),
            makeOperatorSearch: MakeOperatorSearchSpy(),
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
    
    private func makePaymentsSuccess(
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
    
    private func makeQRFailed(
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
    ) -> (mixed: MultiElementArray<SegmentedOperatorProvider>, qrCode: QRCode, qrMapping: QRMapping) {
        
        return (makeMixedOperators(), makeQR(), makeQRMapping())
    }
    
    private func makeMappedMixed() -> QRModelResult {
        
        return .mapped(.mixed(makeMixedOperators(), makeQR(), makeQRMapping()))
    }
    
    private func makeProviderPicker() -> QRNavigation.ProviderPicker {
        
        let (mix, qrCode, qrMapping) = makeMixed()
        return .preview(mix: mix, qrCode: qrCode, qrMapping: qrMapping)
    }
    
    private func makeProviderPickerSuccess(
    ) -> Result<QRNavigation.ProviderPicker, Never> {
        
        return .success(makeProviderPicker())
    }
    
    private func makeMultiple(
    ) -> (multiple: MultiElementArray<SegmentedOperatorData>, qrCode: QRCode, qrMapping: QRMapping) {
        
        return (makeMultipleOperators(), makeQR(), makeQRMapping())
    }
    
    private func makeMappedMultiple() -> QRModelResult {
        
        let (multiple, qrCode, qrMapping) = makeMultiple()
        return .mapped(.multiple(multiple, qrCode, qrMapping))
    }
    
    private func makeMultipleOperators(
        first: SegmentedOperatorData? = nil,
        second: SegmentedOperatorData? = nil,
        tail: SegmentedOperatorData...
    ) -> MultiElementArray<SegmentedOperatorData> {
        
        return .init(first ?? makeSegmentedOperatorData(), second ?? makeSegmentedOperatorData(), tail)
    }
    
    private func makeSegmentedOperatorData(
        origin: OperatorGroupData.OperatorData? = nil,
        segment: String = anyMessage()
    ) -> SegmentedOperatorData {
        
        return .init(origin: origin ?? makeOperatorGroupDataOperatorData(), segment: segment)
    }
    
    private func makeOperatorGroupDataOperatorData(
        city: String? = nil,
        code: String = anyMessage(),
        isGroup: Bool = false,
        logotypeList: [OperatorGroupData.LogotypeData] = [],
        name: String = anyMessage(),
        parameterList: [ParameterData] = [],
        parentCode: String = anyMessage(),
        region: String? = nil,
        synonymList: [String] = []
    ) -> OperatorGroupData.OperatorData {
        
        return .init(city: city, code: code, isGroup: isGroup, logotypeList: logotypeList, name: name, parameterList: parameterList, parentCode: parentCode, region: region, synonymList: synonymList)
    }
    
    private func makeOperatorSearchSuccess(
    ) -> Result<QRNavigation.OperatorSearch, Never> {
        
        return .success(makeOperatorSearch())
    }
    
    private func makeOperatorSearch() -> QRNavigation.OperatorSearch {
        
        return .init(searchBar: .banks(), navigationBar: .sample, model: .emptyMock, addCompanyAction: {}, requisitesAction: {})
    }
    
    private func makePaymentProviderServicePickerPayload(
        provider: SegmentedProvider? = nil,
        qrCode: QRCode? = nil,
        qrMapping: QRMapping? = nil
    ) -> PaymentProviderServicePickerPayload {
        
        return .init(provider: provider ?? makeSegmentedProvider(), qrCode: qrCode ?? makeQR(), qrMapping: qrMapping ?? makeQRMapping())
    }
    
    private func makeSegmentedProvider(
        origin: UtilityPaymentProvider? = nil,
        segment: String = anyMessage()
    ) -> SegmentedProvider {
        
        return .init(origin: origin ?? makeUtilityPaymentProvider(), segment: segment)
    }
    
    private func makeUtilityPaymentProvider(
        id: String = anyMessage(),
        icon: String? = nil,
        inn: String? = nil,
        title: String = anyMessage(),
        segment: String = anyMessage()
    ) -> UtilityPaymentProvider {
        
        return .init(id: id, icon: icon, inn: inn, title: title, segment: segment)
    }
    
    private func makeServicePickerSuccess(
    ) -> Result<SUT.MicroServices.ServicePicker, Never> {
        
        return .success(makeServicePicker())
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
    
    private func makeInternetTVSuccess(
    ) -> Result<InternetTVDetailsViewModel, Never> {
        
        return .success(.init(model: .mockWithEmptyExcept(), closeAction: {}))
    }
    
    private func makeErrorMessage(
        title: String = anyMessage(),
        message: String = anyMessage()
    ) -> QRNavigation.ErrorMessage {
        
        return .init(title: title, message: message)
    }
    
    private func makeSberQRConfirmPaymentState(
    ) -> SberQRConfirmPaymentState {
        
        return .init(confirm: .editableAmount(.preview))
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
        toDeliver expectedResult: EquatableQRNavigation,
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
        toDeliver expectedResult: EquatableQRNavigation,
        notify: @escaping SUT.Notify = { _ in },
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        
        sut.compose(payload: payload, notify: notify) {
            
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
        
        sut.compose(
            with: qrResult,
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

// MARK: - DSL

private extension QRNavigationComposer {
    
    func compose(
        with qrResult: QRModelResult
    ) {
        compose(
            payload: .qrResult(qrResult),
            notify: { _ in },
            completion: { _ in }
        )
    }
    
    func compose(
        url: URL,
        state: SberQRConfirmPaymentState
    ) {
        compose(
            payload: .sberPay(url, state),
            notify: { _ in },
            completion: { _ in }
        )
    }
    
    func compose(
        with qrResult: QRModelResult,
        notify: @escaping Notify
    ) {
        compose(
            payload: .qrResult(qrResult),
            notify: notify,
            completion: { _ in }
        )
    }
    
    func compose(
        with qrResult: QRModelResult,
        notify: @escaping Notify,
        completion: @escaping QRNavigationCompletion
    ) {
        compose(
            payload: .qrResult(qrResult),
            notify: notify,
            completion: completion
        )
    }
}

private extension QRNavigation {
    
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
    
    // MARK: - equatable
    
    var equatable: EquatableQRNavigation {
        
        switch self {
        case .failure:            return .failure
        case .internetTV:         return .internetTV
        case .operatorSearch:     return .operatorSearch
        case .payments:           return .payments

        case let .paymentComplete(paymentsSuccess):
            return .paymentComplete(paymentsSuccess.result)

        case .providerPicker:     return .providerPicker

        case let .sberQR(sberQR):
            return .sberQR(sberQR.result)

        case .servicePicker:      return .servicePicker
        }
    }
}

private enum EquatableQRNavigation: Equatable {
    
    case failure
    case internetTV
    case operatorSearch
    case payments
    case providerPicker
    case paymentComplete(Result)
    case sberQR(Result)
    case servicePicker
    
    enum Result: Equatable {
        
        case failure(QRNavigation.ErrorMessage)
        case success
    }
}

private extension QRNavigation.SberQRResult {
    
    var result: EquatableQRNavigation.Result {
        
        switch self {
        case let .failure(error): return .failure(error)
        case .success:            return .success
        }
    }
}
 
private extension QRNavigation.PaymentCompleteResult {
    
    var result: EquatableQRNavigation.Result {
        
        switch self {
        case let .failure(error): return .failure(error)
        case .success:            return .success
        }
    }
}

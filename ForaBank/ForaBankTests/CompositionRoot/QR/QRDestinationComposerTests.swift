//
//  QRDestinationComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.10.2024.
//

import Combine
import ForaTools

final class QRDestinationComposer {
    
    private let makeInternetTV: MakeInternetTV
    private let makePayments: MakePayments
    private let makeQRFailure: MakeQRFailure
    private let makeQRFailureWithQR: MakeQRFailureWithQR
    private let makeProviderPicker: MakeProviderPicker
    private let makeOperatorSearch: MakeOperatorSearch
    private let makeDetailPayments: MakeDetailPayments
    private let makeServicePicker: MakeServicePicker
    private let makeSourcePayments: MakeSourcePayments
    
    init(
        makeInternetTV: @escaping MakeInternetTV,
        makePayments: @escaping MakePayments,
        makeQRFailure: @escaping MakeQRFailure,
        makeQRFailureWithQR: @escaping MakeQRFailureWithQR,
        makeProviderPicker: @escaping MakeProviderPicker,
        makeOperatorSearch: @escaping MakeOperatorSearch,
        makeDetailPayments: @escaping MakeDetailPayments,
        makeServicePicker: @escaping MakeServicePicker,
        makeSourcePayments: @escaping MakeSourcePayments
    ) {
        self.makeInternetTV = makeInternetTV
        self.makePayments = makePayments
        self.makeQRFailure = makeQRFailure
        self.makeQRFailureWithQR = makeQRFailureWithQR
        self.makeProviderPicker = makeProviderPicker
        self.makeOperatorSearch = makeOperatorSearch
        self.makeDetailPayments = makeDetailPayments
        self.makeServicePicker = makeServicePicker
        self.makeSourcePayments = makeSourcePayments
    }
}

extension QRDestinationComposer {
    
    typealias MakeInternetTV = ((QRCode, QRMapping), @escaping (InternetTVDetailsViewModel) -> Void) -> Void
    
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
    
    struct MakeProviderPickerPayload: Equatable {
        
        let mixed: MultiElementArray<SegmentedOperatorProvider>
        let qrCode: QRCode
        let qrMapping: QRMapping
    }
    
    typealias ProviderPicker = SegmentedPaymentProviderPickerFlowModel
    typealias MakeProviderPicker = (MakeProviderPickerPayload, @escaping (ProviderPicker) -> Void) -> Void
    
    struct MakeOperatorSearchPayload: Equatable {
        
        let multiple: MultiElementArray<SegmentedOperatorData>
        let qrCode: QRCode
        let qrMapping: QRMapping
    }
    
    typealias OperatorSearch = QRSearchOperatorViewModel
    typealias MakeOperatorSearch = (MakeOperatorSearchPayload, @escaping (OperatorSearch) -> Void) -> Void
    
    typealias MakeDetailPayments = (QRCode, @escaping (ClosePaymentsViewModelWrapper) -> Void) -> Void
    
    typealias ServicePicker = AnywayServicePickerFlowModel
    typealias MakeServicePicker = (PaymentProviderServicePickerPayload, @escaping (ServicePicker) -> Void) -> Void
    
    typealias MakeSourcePayments = (Payments.Operation.Source, @escaping (ClosePaymentsViewModelWrapper) -> Void) -> Void
}

extension QRDestinationComposer {
    
    func compose(
        result: QRModelResult,
        notify: @escaping Notify,
        completion: @escaping QRDestinationCompletion
    ) {
        handle(result: result, with: notify, and: completion)
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
        
        case c2bSubscribe(PaymentsNode)
        case c2b(PaymentsNode)
        case detailPayments(PaymentsNode)
        case failure(QRFailedViewModel)
        case internetTV(InternetTVDetailsViewModel)
        case operatorSearch(OperatorSearch)
        case payments(PaymentsNode)
        case providerPicker(Node<ProviderPicker>)
        case servicePicker(Node<AnywayServicePickerFlowModel>)
        
        typealias PaymentsNode = Node<ClosePaymentsViewModelWrapper>
    }
    
    typealias Notify = (NotifyEvent) -> Void
    typealias QRDestinationCompletion = (QRDestination) -> Void
}

private extension QRDestinationComposer {
    
    func handle(
        result: QRModelResult,
        with notify: @escaping Notify,
        and completion: @escaping QRDestinationCompletion
    ) {
        switch result {
        case let .c2bSubscribeURL(url):
            makePayments(.c2bSubscribe(url)) { [weak self] in
                
                guard let self else { return }
                
                completion(.c2bSubscribe(.init(
                    model: $0,
                    cancellables: self.bind($0, with: notify)
                )))
            }
            
        case let .c2bURL(url):
            makePayments(.c2b(url)) { [weak self] in
                
                guard let self else { return }
                
                completion(.c2b(.init(
                    model: $0,
                    cancellables: self.bind($0, with: notify)
                )))
            }
            
        case let .failure(qrCode):
            let payload = MakeQRFailureWithQRPayload(
                qrCode: qrCode,
                chat: { notify(.outside(.chat)) },
                detailPayment: { notify(.detailPayment($0)) }
            )
            makeQRFailureWithQR(payload) { completion(.failure($0)) }
            
        case let .mapped(mapped):
            handle(mapped: mapped, with: notify, and: completion)
            
        case let .sberQR(url):
#warning("unimplemented")
            fatalError(String(describing: url))
            
        case .url(_):
            let payload = MakeQRFailurePayload(
                chat: { notify(.outside(.chat)) },
                detailPayment: { notify(.detailPayment(nil)) }
            )
            makeQRFailure(payload) { completion(.failure($0)) }
            
        case .unknown:
            let payload = MakeQRFailurePayload(
                chat: { notify(.outside(.chat)) },
                detailPayment: { notify(.detailPayment(nil)) }
            )
            makeQRFailure(payload) { completion(.failure($0)) }
        }
    }
    
    func handle(
        mapped: QRModelResult.Mapped,
        with notify: @escaping Notify,
        and completion: @escaping QRDestinationCompletion
    ) {
        switch mapped {
        case .missingINN:
#warning("same as in url and unknown cases")
            let payload = MakeQRFailurePayload(
                chat: { notify(.outside(.chat)) },
                detailPayment: { notify(.detailPayment(nil)) }
            )
            makeQRFailure(payload) { completion(.failure($0)) }
            
        case let .mixed(mixed, qrCode, qrMapping):
            let payload = MakeProviderPickerPayload(
                mixed: mixed,
                qrCode: qrCode,
                qrMapping: qrMapping
            )
            makeProviderPicker(payload) { [weak self] in
                
                guard let self else { return }
                
                completion(.providerPicker(.init(
                    model: $0,
                    cancellables: self.bind($0, with: notify)
                )))
            }
            
        case let .multiple(multiple, qrCode, qrMapping):
            let payload = MakeOperatorSearchPayload(
                multiple: multiple,
                qrCode: qrCode,
                qrMapping: qrMapping
            )
            makeOperatorSearch(payload) { completion(.operatorSearch($0)) }
            
        case let .none(qrCode):
            makeDetailPayments(qrCode) { [weak self] in
                
                guard let self else { return }
                
                completion(.detailPayments(.init(
                    model: $0,
                    cancellables: bind($0, with: notify)
                )))
            }
            
        case let .provider(payload):
            makeServicePicker(payload) { [weak self] in
                
                guard let self else { return }
                
                completion(.servicePicker(.init(
                    model: $0,
                    cancellables: self.bind($0, with: notify)
                )))
            }
            
        case let .single(_, qrCode, qrMapping):
            makeInternetTV((qrCode, qrMapping)) { completion(.internetTV($0)) }
            
        case let .source(source):
            makeSourcePayments(source) { [weak self] in
                
                guard let self else { return }
                
                completion(.payments(.init(
                    model: $0,
                    cancellables: self.bind($0, with: notify)
                )))
            }
        }
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

private extension AnywayServicePickerFlowState {
    
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
        
        let (sut, makeInternetTV, makePayments, makeQRFailure, makeQRFailureWithQR, makeProviderPicker, makeOperatorSearch, makeDetailPayments, makeServicePicker, makeSourcePayments) = makeSUT()
        
        XCTAssertEqual(makeInternetTV.callCount, 0)
        XCTAssertEqual(makePayments.callCount, 0)
        XCTAssertEqual(makeQRFailure.callCount, 0)
        XCTAssertEqual(makeQRFailureWithQR.callCount, 0)
        XCTAssertEqual(makeProviderPicker.callCount, 0)
        XCTAssertEqual(makeOperatorSearch.callCount, 0)
        XCTAssertEqual(makeDetailPayments.callCount, 0)
        XCTAssertEqual(makeServicePicker.callCount, 0)
        XCTAssertEqual(makeSourcePayments.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - c2bSubscribe
    
    func test_c2bSubscribe_shouldCallMakeC2BSubscribeWithURL() {
        
        let url = anyURL()
        let (sut, _, makePayments, _,_,_,_,_,_,_) = makeSUT()
        
        sut.compose(result: .c2bSubscribeURL(url), notify: { _ in }) { _ in }
        
        XCTAssertNoDiff(makePayments.payloads, [.c2bSubscribe(url)])
    }
    
    func test_c2bSubscribe_shouldDeliverC2BSubscribe() {
        
        let (sut, _, makePayments, _,_,_,_,_,_,_) = makeSUT()
        
        expect(sut, with: .c2bSubscribeURL(anyURL()), toDeliver: .c2bSubscribe, on: {
            
            makePayments.complete(with: makePaymentsSuccess())
        })
    }
    
    func test_c2bSubscribe_shouldDeliverDismissEventOnC2BSubscribeClose() {
        
        let (sut, _, makePayments, _,_,_,_,_,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bSubscribeURL(anyURL()),
            delivers: .dismiss,
            for: { $0.c2bSubscribe?.closeAction() },
            on: { makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_c2bSubscribe_shouldDeliverScanQREventOnC2BSubscribeScanQRCode() {
        
        let (sut, _, makePayments, _,_,_,_,_,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bSubscribeURL(anyURL()),
            delivers: .scanQR,
            for: { $0.c2bSubscribe?.scanQRCode() },
            on: { makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_c2bSubscribe_shouldDeliverContactAbroadEventOnC2BSubscribeContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, _, makePayments, _,_,_,_,_,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bSubscribeURL(anyURL()),
            delivers: .contactAbroad(source),
            for: { $0.c2bSubscribe?.contactAbroad(source: source) },
            on: { makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    // MARK: - c2b
    
    func test_c2b_shouldCallMakeC2BWithURL() {
        
        let url = anyURL()
        let (sut, _, makePayments, _,_,_,_,_,_,_) = makeSUT()
        
        sut.compose(result: .c2bURL(url), notify: { _ in }) { _ in }
        
        XCTAssertNoDiff(makePayments.payloads, [.c2b(url)])
    }
    
    func test_c2b_shouldDeliverC2B() {
        
        let (sut, _, makePayments, _,_,_,_,_,_,_) = makeSUT()
        
        expect(sut, with: .c2bURL(anyURL()), toDeliver: .c2b, on: {
            
            makePayments.complete(with: makePaymentsSuccess())
        })
    }
    
    func test_c2b_shouldDeliverDismissEventOnC2BClose() {
        
        let (sut, _, makePayments, _,_,_,_,_,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bURL(anyURL()),
            delivers: .dismiss,
            for: { $0.c2b?.closeAction() },
            on: { makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_c2b_shouldDeliverScanQREventOnC2BScanQRCode() {
        
        let (sut, _, makePayments, _,_,_,_,_,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bURL(anyURL()),
            delivers: .scanQR,
            for: { $0.c2b?.scanQRCode() },
            on: { makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_c2b_shouldDeliverContactAbroadEventOnC2BContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, _, makePayments, _,_,_,_,_,_,_) = makeSUT()
        
        expect(
            sut,
            result: .c2bURL(anyURL()),
            delivers: .contactAbroad(source),
            for: { $0.c2b?.contactAbroad(source: source) },
            on: { makePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    // MARK: - failure
    
    func test_failure_shouldCallMakeQRFailureWithQR() {
        
        let qrCode = makeQR()
        let (sut, _,_,_, makeQRFailure, _,_,_,_,_) = makeSUT()
        
        sut.compose(result: .failure(qrCode), notify: { _ in }) { _ in }
        
        XCTAssertNoDiff(makeQRFailure.payloads.map(\.qrCode), [qrCode])
    }
    
    func test_failure_shouldDeliverFailure() {
        
        let (sut, _,_,_, makeQRFailure, _,_,_,_,_) = makeSUT()
        
        expect(sut, with: .failure(makeQR()), toDeliver: .failure, on: {
            
            makeQRFailure.complete(with: .success(makeQRFailedViewModel()))
        })
    }
    
    func test_failure_shouldDeliverOutsideChatEventOnFailureChatAction() {
        
        let (sut, _,_,_, makeQRFailure, _,_,_,_,_) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .failure(makeQR()), notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events, [.outside(.chat)])
    }
    
    func test_failure_shouldDeliverDetailPaymentEventOnFailureDetailPaymentAction() {
        
        let qrCode = makeQR()
        let (sut, _,_,_, makeQRFailure, _,_,_,_,_) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .failure(makeQR()), notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.detailPayment)?(qrCode)
        
        XCTAssertNoDiff(events, [.detailPayment(qrCode)])
    }
    
    // MARK: - mapped: missingINN
    
    func test_missingINN_shouldCallMakeQRFailure() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        
        sut.compose(result: .mapped(.missingINN), notify: { _ in }) { _ in }
        
        XCTAssertEqual(makeQRFailure.payloads.count, 1)
    }
    
    func test_missingINN_shouldDeliverFailureOnMissingINN() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        
        expect(sut, with: .mapped(.missingINN), toDeliver: .failure, on: {
            
            makeQRFailure.complete(with: .success(makeQRFailedViewModel()))
        })
    }
    
    func test_missingINN_shouldDeliverOutsideChatEventOnFailureChatAction() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .mapped(.missingINN), notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events, [.outside(.chat)])
    }
    
    func test_missingINN_shouldDeliverDetailPaymentEventOnFailureDetailPaymentAction() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .mapped(.missingINN), notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.detailPayment)?()
        
        XCTAssertNoDiff(events, [.detailPayment(nil)])
    }
    
    // MARK: - mapped: mixed
    
    func test_mapped_mixed_shouldCallMakeProviderPickerWithPayload() {
        
        let (mixed, qrCode, qrMapping) = makeMixed()
        let result: QRModelResult = .mapped(.mixed(mixed, qrCode, qrMapping))
        let (sut, _,_,_,_, makeProviderPicker, _,_,_,_) = makeSUT()
        
        sut.compose(result: result, notify: { _ in }, completion: { _ in })
        
        XCTAssertNoDiff(makeProviderPicker.payloads, [
            .init(mixed: mixed, qrCode: qrCode, qrMapping: qrMapping)
        ])
    }
    
    func test_mapped_mixed_shouldDeliverProviderPicker() {
        
        let (sut, _,_,_,_, makeProviderPicker, _,_,_,_) = makeSUT()
        
        expect(sut, with: makeMappedMixed(), toDeliver: .providerPicker, on: {
            
            makeProviderPicker.complete(with: makeProviderPickerSuccess())
        })
    }
    
#warning("FIXME")
    //    func test_mapped_mixed_shouldDeliverIsLoadingTrueEventOnProviderPickerEvent() {
    //
    //        let (sut, _,_,_,_, makeProviderPicker, _,_,_,_) = makeSUT()
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
    //        let (sut, _,_,_,_, makeProviderPicker, _,_,_,_) = makeSUT()
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
        
        let (sut, _,_,_,_, makeProviderPicker, _,_,_,_) = makeSUT()
        
        expect(
            sut,
            result: makeMappedMixed(),
            delivers: .outside(.chat),
            for: { $0.providerPickerGoTo(to: .addCompany) },
            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    func test_mapped_mixed_shouldDeliverOutsideMainEventOnProviderPickerEvent() {
        
        let (sut, _,_,_,_, makeProviderPicker, _,_,_,_) = makeSUT()
        
        expect(
            sut,
            result: makeMappedMixed(),
            delivers: .outside(.main),
            for: { $0.providerPickerGoTo(to: .main) },
            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    func test_mapped_mixed_shouldDeliverOutsidePaymentsEventOnProviderPickerEvent() {
        
        let (sut, _,_,_,_, makeProviderPicker, _,_,_,_) = makeSUT()
        
        expect(
            sut,
            result: makeMappedMixed(),
            delivers: .outside(.payments),
            for: { $0.providerPickerGoTo(to: .payments) },
            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    func test_mapped_mixed_shouldDeliverOutsideScanQREventOnProviderPickerEvent() {
        
        let (sut, _,_,_,_, makeProviderPicker, _,_,_,_) = makeSUT()
        
        expect(
            sut,
            result: makeMappedMixed(),
            delivers: .outside(.scanQR),
            for: { $0.providerPickerGoTo(to: .scanQR) },
            on: { makeProviderPicker.complete(with: makeProviderPickerSuccess()) }
        )
    }
    
    // MARK: - mapped: multiple
    
    func test_mapped_multiple_shouldCallMakeOperatorSearchWithPayload() {
        
        let (multiple, qrCode, qrMapping) = makeMultiple()
        let result: QRModelResult = .mapped(.multiple(multiple, qrCode, qrMapping))
        let (sut, _,_,_,_,_, makeOperatorSearch, _,_,_) = makeSUT()
        
        sut.compose(result: result, notify: { _ in }, completion: { _ in })
        
        XCTAssertNoDiff(makeOperatorSearch.payloads, [
            .init(multiple: multiple, qrCode: qrCode, qrMapping: qrMapping)
        ])
    }
    
    func test_mapped_multiple_shouldDeliverOperatorSearch() {
        
        let (sut, _,_,_,_,_, makeOperatorSearch, _,_,_) = makeSUT()
        
        expect(sut, with: makeMappedMultiple(), toDeliver: .operatorSearch, on: {
            
            makeOperatorSearch.complete(with: makeOperatorSearchSuccess())
        })
    }
    
    // TODO: add tests for wrapper as in c2bSubscribe
    
    // MARK: - mapped: none
    
    func test_mapped_none_shouldCallMakeDetailPaymentsWithQR() {
        
        let qrCode = makeQR()
        let (sut, _,_,_,_,_,_, makeDetailPayments, _,_) = makeSUT()
        
        sut.compose(result: .mapped(.none(qrCode)), notify: { _ in }, completion: { _ in })
        
        XCTAssertNoDiff(makeDetailPayments.payloads, [qrCode])
    }
    
    func test_mapped_none_shouldDeliverDetailPayments() {
        
        let (sut, _,_,_,_,_,_, makeDetailPayments, _,_) = makeSUT()
        
        expect(sut, with: .mapped(.none(makeQR())), toDeliver: .detailPayments, on: {
            
            makeDetailPayments.complete(with: makePaymentsSuccess())
        })
    }
    
    func test_mapped_none_shouldDeliverDismissEventOnDetailPaymentsClose() {
        
        let (sut, _,_,_,_,_,_, makeDetailPayments, _,_) = makeSUT()
        
        expect(
            sut,
            result: .mapped(.none(makeQR())),
            delivers: .dismiss,
            for: { $0.detailPayments?.closeAction() },
            on: { makeDetailPayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_mapped_none_shouldDeliverScanQREventOnDetailPaymentsScanQRCode() {
        
        let (sut, _,_,_,_,_,_, makeDetailPayments, _,_) = makeSUT()
        
        expect(
            sut,
            result: .mapped(.none(makeQR())),
            delivers: .scanQR,
            for: { $0.detailPayments?.scanQRCode() },
            on: { makeDetailPayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_mapped_none_shouldDeliverContactAbroadEventOnDetailPaymentsContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, _,_,_,_,_,_, makeDetailPayments, _,_) = makeSUT()
        
        expect(
            sut,
            result: .mapped(.none(makeQR())),
            delivers: .contactAbroad(source),
            for: { $0.detailPayments?.contactAbroad(source: source) },
            on: { makeDetailPayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    // MARK: - mapped: provider
    
    func test_mapped_provider_shouldCallMakeServicePickerWithPayload() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, _,_,_,_,_,_,_, makeServicePicker, _) = makeSUT()
        
        sut.compose(result: .mapped(.provider(payload)), notify: { _ in }, completion: { _ in })
        
        XCTAssertNoDiff(makeServicePicker.payloads, [payload])
    }
    
    func test_mapped_provider_shouldDeliverServicePicker() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, _,_,_,_,_,_,_, makeServicePicker, _) = makeSUT()
        
        expect(sut, with: .mapped(.provider(payload)), toDeliver: .servicePicker, on: {
            
            makeServicePicker.complete(with: makeServicePickerSuccess())
        })
    }
    
#warning("FIXME")
    //    func test_mapped_provider_shouldDeliverIsLoadingTrueEventOnServicePickerEvent() {
    //
    //        let (sut, _,_,_,_,_,_,_, makeServicePicker, _) = makeSUT()
    //
    //        expect(
    //            sut,
    //            result: makeMappedMixed(),
    //            delivers: .isLoading(true),
    //            for: { $0.providerPickerSetIsLoading(to: true) },
    //            on: { makeServicePicker.complete(with: makeServicePickerSuccess()) }
    //        )
    //    }
    //
    //    func test_mapped_provider_shouldDeliverIsLoadingFalseEventOnServicePickerEvent() {
    //
    //        let (sut, _,_,_,_,_,_,_, makeServicePicker, _) = makeSUT()
    //
    //        expect(
    //            sut,
    //            result: makeMappedMixed(),
    //            delivers: .isLoading(false),
    //            for: { $0.providerPickerSetIsLoading(to: false) },
    //            on: { makeServicePicker.complete(with: makeServicePickerSuccess()) }
    //        )
    //    }
    
    func test_mapped_provider_shouldDeliverOutsideChatEventOnServicePickerEvent() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, _,_,_,_,_,_,_, makeServicePicker, _) = makeSUT()
        
        expect(
            sut,
            result: .mapped(.provider(payload)),
            delivers: .outside(.chat),
            for: { $0.servicePicker?.event(.goTo(.addCompany)) },
            on: { makeServicePicker.complete(with: makeServicePickerSuccess()) }
        )
    }
    
    func test_mapped_provider_shouldDeliverOutsideMainEventOnServicePickerEvent() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, _,_,_,_,_,_,_, makeServicePicker, _) = makeSUT()
        
        expect(
            sut,
            result: .mapped(.provider(payload)),
            delivers: .outside(.main),
            for: { $0.servicePicker?.event(.goTo(.main)) },
            on: { makeServicePicker.complete(with: makeServicePickerSuccess()) }
        )
    }
    
    func test_mapped_provider_shouldDeliverOutsidePaymentsEventOnServicePickerEvent() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, _,_,_,_,_,_,_, makeServicePicker, _) = makeSUT()
        
        expect(
            sut,
            result: .mapped(.provider(payload)),
            delivers: .outside(.payments),
            for: { $0.servicePicker?.event(.goTo(.payments)) },
            on: { makeServicePicker.complete(with: makeServicePickerSuccess()) }
        )
    }
    
    func test_mapped_provider_shouldDeliverOutsideScanQREventOnServicePickerEvent() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, _,_,_,_,_,_,_, makeServicePicker, _) = makeSUT()
        
        expect(
            sut,
            result: .mapped(.provider(payload)),
            delivers: .outside(.scanQR),
            for: { $0.servicePicker?.event(.goTo(.scanQR)) },
            on: { makeServicePicker.complete(with: makeServicePickerSuccess()) }
        )
    }
    
    // MARK: - mapped: single
    
    func test_mapped_single_shouldCallMakeInternetTVWithPayload() {
        
        let (qrCode, qrMapping) = (makeQR(), makeQRMapping())
        let (sut, makeInternetTV, _,_,_,_,_,_,_,_) = makeSUT()
        
        sut.compose(result: .mapped(.single(makeSegmentedOperatorData(), qrCode, qrMapping)), notify: { _ in }, completion: { _ in })
        
        XCTAssertNoDiff(makeInternetTV.payloads.map(\.0), [qrCode])
        XCTAssertNoDiff(makeInternetTV.payloads.map(\.1), [qrMapping])
    }
    
    func test_mapped_single_shouldDeliverInternetTV() {
        
        let (sut, makeInternetTV, _,_,_,_,_,_,_,_) = makeSUT()
        
        expect(sut, with: makeMappedSingle(), toDeliver: .internetTV, on: {
            
            makeInternetTV.complete(with: makeInternetTVSuccess())
        })
    }
    
    // MARK: - mapped: source
    
    func test_mapped_source_shouldCallMakeSourcePaymentsWithPayload() {
        
        let (sut, _,_,_,_,_,_,_,_, makeSourcePayments) = makeSUT()
        
        sut.compose(result: .mapped(.source(.avtodor)), notify: { _ in }, completion: { _ in })
        
        XCTAssertNoDiff(makeSourcePayments.payloads, [.avtodor])
    }
    
    func test_mapped_source_shouldDeliverPayments() {
        
        let (sut, _,_,_,_,_,_,_,_, makeSourcePayments) = makeSUT()
        expect(sut, with: .mapped(.source(.avtodor)), toDeliver: .payments, on: {
            
            makeSourcePayments.complete(with: makePaymentsSuccess())
        })
    }
    
    func test_mapped_source_shouldDeliverDismissEventOnSourcePaymentsClose() {
        
        let (sut, _,_,_,_,_,_,_,_, makeSourcePayments) = makeSUT()
        expect(
            sut,
            result: .mapped(.source(.avtodor)),
            delivers: .dismiss,
            for: { $0.payments?.closeAction() },
            on: { makeSourcePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_mapped_source_shouldDeliverScanQREventOnSourcePaymentsScanQRCode() {
        
        let (sut, _,_,_,_,_,_,_,_, makeSourcePayments) = makeSUT()
        expect(
            sut,
            result: .mapped(.source(.avtodor)),
            delivers: .scanQR,
            for: { $0.payments?.scanQRCode() },
            on: { makeSourcePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    func test_mapped_source_shouldDeliverContactAbroadEventOnSourcePaymentsContactAbroad() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, _,_,_,_,_,_,_,_, makeSourcePayments) = makeSUT()
        expect(
            sut,
            result: .mapped(.source(.avtodor)),
            delivers: .contactAbroad(source),
            for: { $0.payments?.contactAbroad(source: source) },
            on: { makeSourcePayments.complete(with: makePaymentsSuccess()) }
        )
    }
    
    // MARK: - url
    
    func test_url_shouldCallMakeQRFailure() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        
        sut.compose(result: .url(anyURL()), notify: { _ in }) { _ in }
        
        XCTAssertEqual(makeQRFailure.payloads.count, 1)
    }
    
    func test_url_shouldDeliverFailure() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        
        expect(sut, with: .url(anyURL()), toDeliver: .failure, on: {
            
            makeQRFailure.complete(with: .success(makeQRFailedViewModel()))
        })
    }
    
    func test_url_shouldNotifyWithOutsideChatOnChatAction() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .url(anyURL()), notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events, [.outside(.chat)])
    }
    
    func test_url_shouldNotifyWithWithDetailPaymentAction() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .url(anyURL()), notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.detailPayment)?()
        
        XCTAssertNoDiff(events, [.detailPayment(nil)])
    }
    
    // MARK: - unknown
    
    func test_unknown_shouldCallMakeQRFailure() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        
        sut.compose(result: .unknown, notify: { _ in }) { _ in }
        
        XCTAssertEqual(makeQRFailure.payloads.count, 1)
    }
    
    func test_unknown_shouldDeliverFailure() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        
        expect(sut, with: .unknown, toDeliver: .failure, on: {
            
            makeQRFailure.complete(with: .success(makeQRFailedViewModel()))
        })
    }
    
    func test_unknown_shouldNotifyWithOutsideChatOnChatAction() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .unknown, notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.chat)?()
        
        XCTAssertNoDiff(events, [.outside(.chat)])
    }
    
    func test_unknown_shouldNotifyWithWithDetailPaymentAction() {
        
        let (sut, _,_, makeQRFailure, _,_,_,_,_,_) = makeSUT()
        var events = [SUT.NotifyEvent]()
        
        sut.compose(result: .unknown, notify: { events.append($0) }) { _ in }
        makeQRFailure.payloads.first.map(\.detailPayment)?()
        
        XCTAssertNoDiff(events, [.detailPayment(nil)])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRDestinationComposer
    private typealias MakeInternetTV = Spy<(QRCode, QRMapping), InternetTVDetailsViewModel, Never>
    private typealias MakePaymentsSpy = Spy<SUT.Source, ClosePaymentsViewModelWrapper, Never>
    private typealias MakeDetailPaymentsSpy = Spy<QRCode, ClosePaymentsViewModelWrapper, Never>
    private typealias MakeSourcePaymentsSpy = Spy<Payments.Operation.Source, ClosePaymentsViewModelWrapper, Never>
    private typealias MakeQRFailure = Spy<SUT.MakeQRFailurePayload, QRFailedViewModel, Never>
    private typealias MakeQRFailureWithQR = Spy<SUT.MakeQRFailureWithQRPayload, QRFailedViewModel, Never>
    private typealias MakeProviderPicker = Spy<SUT.MakeProviderPickerPayload, SUT.ProviderPicker, Never>
    private typealias MakeOperatorSearch = Spy<SUT.MakeOperatorSearchPayload, SUT.OperatorSearch, Never>
    private typealias MakeServicePickerSpy = Spy<PaymentProviderServicePickerPayload, SUT.ServicePicker, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeInternetTV: MakeInternetTV,
        makePaymentsSpy: MakePaymentsSpy,
        makeQRFailure: MakeQRFailure,
        makeQRFailureWithQR: MakeQRFailureWithQR,
        makeProviderPicker: MakeProviderPicker,
        makeOperatorSearch: MakeOperatorSearch,
        makeDetailPayments: MakeDetailPaymentsSpy,
        makeServicePicker: MakeServicePickerSpy,
        makeSourcePayments: MakeSourcePaymentsSpy
    ) {
        let makeInternetTV = MakeInternetTV()
        let makePaymentsSpy = MakePaymentsSpy()
        let makeQRFailureWithQR = MakeQRFailureWithQR()
        let makeQRFailure = MakeQRFailure()
        let makeProviderPicker = MakeProviderPicker()
        let makeOperatorSearch = MakeOperatorSearch()
        let makeDetailPayments = MakeDetailPaymentsSpy()
        let makeServicePicker = MakeServicePickerSpy()
        let makeSourcePayments = MakeSourcePaymentsSpy()
        let sut = SUT(
            makeInternetTV: makeInternetTV.process(_:completion:),
            makePayments: makePaymentsSpy.process(_:completion:),
            makeQRFailure: makeQRFailure.process(_:completion:),
            makeQRFailureWithQR: makeQRFailureWithQR.process(_:completion:),
            makeProviderPicker: makeProviderPicker.process(_:completion:),
            makeOperatorSearch: makeOperatorSearch.process(_:completion:),
            makeDetailPayments: makeDetailPayments.process(_:completion:),
            makeServicePicker: makeServicePicker.process(_:completion:),
            makeSourcePayments: makeSourcePayments.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeInternetTV, file: file, line: line)
        trackForMemoryLeaks(makePaymentsSpy, file: file, line: line)
        trackForMemoryLeaks(makeQRFailure, file: file, line: line)
        trackForMemoryLeaks(makeQRFailureWithQR, file: file, line: line)
        trackForMemoryLeaks(makeProviderPicker, file: file, line: line)
        trackForMemoryLeaks(makeOperatorSearch, file: file, line: line)
        trackForMemoryLeaks(makeDetailPayments, file: file, line: line)
        trackForMemoryLeaks(makeServicePicker, file: file, line: line)
        trackForMemoryLeaks(makeSourcePayments, file: file, line: line)
        
        return (sut, makeInternetTV, makePaymentsSpy, makeQRFailure, makeQRFailureWithQR, makeProviderPicker, makeOperatorSearch, makeDetailPayments, makeServicePicker, makeSourcePayments)
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
    ) -> (mixed: MultiElementArray<SegmentedOperatorProvider>, qrCode: QRCode, qrMapping: QRMapping) {
        
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
    ) -> Result<SUT.OperatorSearch, Never> {
        
        return .success(makeOperatorSearch())
    }
    
    private func makeOperatorSearch() -> SUT.OperatorSearch {
        
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
    ) -> Result<SUT.ServicePicker, Never> {
        
        return .success(makeServicePicker())
    }
    
    private func makeServicePicker(
    ) -> SUT.ServicePicker {
        
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

private extension QRDestinationComposer.QRDestination {
    
    // MARK: - c2bSubscribe
    
    var c2bSubscribe: ClosePaymentsViewModelWrapper? {
        
        guard case let .c2bSubscribe(c2bSubscribe) = self
        else { return nil }
        
        return c2bSubscribe.model
    }
    
    // MARK: - c2b
    
    var c2b: ClosePaymentsViewModelWrapper? {
        
        guard case let .c2b(c2b) = self
        else { return nil }
        
        return c2b.model
    }
    
    // MARK: - detailPayments
    
    var detailPayments: ClosePaymentsViewModelWrapper? {
        
        guard case let .detailPayments(detailPayments) = self
        else { return nil }
        
        return detailPayments.model
    }
    
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
    
    func providerPickerSetIsLoading(to isLoading: Bool) {
        
        providerPicker?.event(.isLoading(isLoading))
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
    
    var equatable: EquatableQRDestination {
        
        switch self {
        case .c2bSubscribe:   return .c2bSubscribe
        case .c2b:            return .c2b
        case .detailPayments: return .detailPayments
        case .failure:        return .failure
        case .internetTV:     return .internetTV
        case .operatorSearch: return .operatorSearch
        case .payments:       return .payments
        case .providerPicker: return .providerPicker
        case .servicePicker:  return .servicePicker
        }
    }
}

private enum EquatableQRDestination: Equatable {
    
    case c2bSubscribe
    case c2b
    case detailPayments
    case failure
    case internetTV
    case operatorSearch
    case payments
    case providerPicker
    case servicePicker
}

//
//  PaymentsTransfersPersonalTransfersNavigationComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 23.10.2024.
//

@testable import ForaBank
import XCTest

final class PaymentsTransfersPersonalTransfersNavigationComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.makeAbroad.callCount, 0)
        XCTAssertEqual(spies.makeAnotherCard.callCount, 0)
        XCTAssertEqual(spies.makeContacts.callCount, 0)
        XCTAssertEqual(spies.makeDetail.callCount, 0)
        XCTAssertEqual(spies.makeLatest.callCount, 0)
        XCTAssertEqual(spies.makeMeToMe.callCount, 0)
        XCTAssertEqual(spies.makeSource.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - buttonType
    
    func test_abroad_shouldCallMakeAbroad() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.abroad)
        
        XCTAssertEqual(spies.makeAbroad.callCount, 1)
    }
    
    func test_abroad_shouldDeliverContacts() {
        
        let abroad = makeAbroad()
        let (sut, _) = makeSUT(abroad: abroad)
        
        let navigation = sut.compose(.abroad)
        
        switch navigation {
        case let .contacts(received):
            XCTAssert(abroad === received.model)
            
        default:
            XCTFail("Expected abroad contacts, got \(String(describing: navigation)) instead.")
        }
    }
    
    func test_anotherCard_shouldCallMakeAnotherCard() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.anotherCard)
        
        XCTAssertEqual(spies.makeAnotherCard.callCount, 1)
    }
    
    func test_anotherCard_shouldDeliverAnotherCard() {
        
        let anotherCard = makeAnotherCard()
        let (sut, _) = makeSUT(anotherCard: anotherCard)
        
        let navigation = sut.compose(.anotherCard)
        
        switch navigation {
        case let .payments(received):
            XCTAssert(anotherCard === received.model)
            
        default:
            XCTFail("Expected another card, got \(String(describing: navigation)) instead.")
        }
    }
    
    func test_betweenSelf_shouldCallMakeContacts() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.betweenSelf)
        
        XCTAssertEqual(spies.makeMeToMe.callCount, 1)
    }
    
    func test_betweenSelf_shouldDeliverNilOnNil() {
        
        let (sut, _) = makeSUT(meToMe: nil)
        
        let navigation = sut.compose(.betweenSelf)
        
        switch navigation {
        case .none:
            break
            
        default:
            XCTFail("Expected nil navigation, got \(String(describing: navigation)) instead.")
        }
    }
    
    func test_betweenSelf_shouldDeliverMeToMe() throws {
        
        let meToMe = try makeMeToMeNode()
        let (sut, _) = makeSUT(meToMe: meToMe)
        
        let navigation = sut.compose(.betweenSelf)
        
        switch navigation {
        case let .meToMe(received):
            XCTAssert(meToMe.model === received.model)
            
        default:
            XCTFail("Expected nil navigation, got \(String(describing: navigation)) instead.")
        }
    }
    
    func test_byPhoneNumber_shouldCallMakeContacts() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.byPhoneNumber)
        
        XCTAssertEqual(spies.makeContacts.callCount, 1)
    }
    
    func test_byPhoneNumber_shouldDeliverContacts() {
        
        let contacts = makeContactsViewModel()
        let (sut, _) = makeSUT(contacts: contacts)
        
        let navigation = sut.compose(.byPhoneNumber)
        
        switch navigation {
        case let .contacts(received):
            XCTAssert(contacts === received.model)
            
        default:
            XCTFail("Expected contacts, got \(String(describing: navigation)) instead.")
        }
    }
    
    func test_requisites_shouldCallMakeDetail() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.requisites)
        
        XCTAssertEqual(spies.makeDetail.callCount, 1)
    }
    
    func test_requisites_shouldDeliverDetail() {
        
        let detail = makeDetailPayment()
        let (sut, _) = makeSUT(detail: detail)
        
        let navigation = sut.compose(.requisites)
        
        switch navigation {
        case let .payments(received):
            XCTAssert(detail === received.model)
            
        default:
            XCTFail("Expected contacts, got \(String(describing: navigation)) instead.")
        }
    }
    
    // MARK: - contactAbroad
    
    func test_contactAbroad_shouldCallMakeSource() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.contactAbroad(source)) { _ in }
        
        XCTAssertNoDiff(spies.makeSource.payloads.map(\.0), [source])
    }
    
    func test_contactAbroad_shouldDeliverSource() throws {
        
        let source = makeSourcePayment()
        let (sut, _) = makeSUT(sourcePayment: source)
        
        let navigation = sut.compose(.contactAbroad(.avtodor)) { _ in }
        
        switch navigation {
        case let .paymentsViewModel(received):
            try XCTAssert(XCTUnwrap(source.model) === XCTUnwrap(received.model))
            
        default:
            XCTFail("Expected payments, got \(String(describing: navigation)) instead.")
        }
    }
    
    // MARK: - contacts
    
    func test_contacts_shouldCallMakeSource() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.contacts(source)) { _ in }
        
        XCTAssertNoDiff(spies.makeSource.payloads.map(\.0), [source])
    }
    
    func test_contacts_shouldDeliverSource() throws {
        
        let source = makeSourcePayment()
        let (sut, _) = makeSUT(sourcePayment: source)
        
        let navigation = sut.compose(.contacts(.avtodor)) { _ in }
        
        switch navigation {
        case let .paymentsViewModel(received):
            try XCTAssert(XCTUnwrap(source.model) === XCTUnwrap(received.model))
            
        default:
            XCTFail("Expected payments, got \(String(describing: navigation)) instead.")
        }
    }
    
    // MARK: - countries
    
    func test_countries_shouldCallMakeSource() {
        
        let source: Payments.Operation.Source = .avtodor
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.countries(source)) { _ in }
        
        XCTAssertNoDiff(spies.makeSource.payloads.map(\.0), [source])
    }
    
    func test_countries_shouldDeliverSource() throws {
        
        let source = makeSourcePayment()
        let (sut, _) = makeSUT(sourcePayment: source)
        
        let navigation = sut.compose(.countries(.avtodor)) { _ in }
        
        switch navigation {
        case let .paymentsViewModel(received):
            try XCTAssert(XCTUnwrap(source.model) === XCTUnwrap(received.model))
            
        default:
            XCTFail("Expected payments, got \(String(describing: navigation)) instead.")
        }
    }
    
    // MARK: - latest
    
    func test_latest_shouldCallMakeLatestPayment() {
        
        let latestID: LatestPaymentData.ID = .random(in: 1...100)
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.latest(latestID)) { _ in }
        
        XCTAssertNoDiff(spies.makeLatest.payloads.map(\.0), [latestID])
    }
    
    func test_latest_shouldDeliverNilOnNil() {
        
        let (sut, _) = makeSUT(latestPayment: nil)
        
        XCTAssertNil(sut.compose(.latest(.random(in: 1...100))) { _ in })
    }
    
    func test_latest_shouldDeliverLatestPayment() throws {
        
        let latest = makeLatestPayment()
        let (sut, _) = makeSUT(latestPayment: latest)
        
        let navigation = sut.compose(.latest(.random(in: 1...100))) { _ in }
        
        switch navigation {
        case let .payments(received):
            try XCTAssert(XCTUnwrap(latest.model) === XCTUnwrap(received.model))
            
        default:
            XCTFail("Expected payments, got \(String(describing: navigation)) instead.")
        }
    }
    
    // MARK: - scanQR
    
    func test_scanQR_shouldCallMakeQR() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.qr(.scan)) { _ in }
        
        XCTAssertNoDiff(spies.makeScanQR.payloads.count, 1)
    }
    
    func test_scanQR_shouldDeliverSourcePayment() throws {
        
        let scanQR = makeScanQRNode()
        let (sut, _) = makeSUT(scanQR: scanQR)
        
        let navigation = sut.compose(.qr(.scan)) { _ in }
        
        switch navigation {
        case let .scanQR(received):
            try XCTAssert(XCTUnwrap(scanQR.model) === XCTUnwrap(received.model))
            
        default:
            XCTFail("Expected scanQR, got \(String(describing: navigation)) instead.")
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersPersonalTransfersNavigationComposer
    private typealias Notify = (SUT.Domain.FlowEvent) -> Void
    private typealias MakeAbroad = CallSpy<Notify, Node<ContactsViewModel>>
    private typealias MakeAnotherCard = CallSpy<Notify, Node<ClosePaymentsViewModelWrapper>>
    private typealias MakeContacts = CallSpy<Notify, Node<ContactsViewModel>>
    private typealias MakeDetail = CallSpy<Notify, Node<ClosePaymentsViewModelWrapper>>
    private typealias MakeLatest = CallSpy<(LatestPaymentData.ID, Notify), Node<ClosePaymentsViewModelWrapper>?>
    private typealias MakeMeToMe = CallSpy<Notify, Node<PaymentsMeToMeViewModel>?>
    private typealias MakeScanQR = CallSpy<Notify, Node<QRModel>>
    private typealias MakeSource = CallSpy<(Payments.Operation.Source, Notify), Node<PaymentsViewModel>>
    
    private struct Spies {
        
        let makeAbroad: MakeAbroad
        let makeAnotherCard: MakeAnotherCard
        let makeContacts: MakeContacts
        let makeDetail: MakeDetail
        let makeLatest: MakeLatest
        let makeMeToMe: MakeMeToMe
        let makeScanQR: MakeScanQR
        let makeSource: MakeSource
    }
    
    private func makeSUT(
        anotherCard: ClosePaymentsViewModelWrapper? = nil,
        abroad: ContactsViewModel? = nil,
        contacts: ContactsViewModel? = nil,
        detail: ClosePaymentsViewModelWrapper? = nil,
        latestPayment: Node<ClosePaymentsViewModelWrapper>? = nil,
        meToMe: Node<PaymentsMeToMeViewModel>? = nil,
        scanQR: Node<QRModel>? = nil,
        sourcePayment: Node<PaymentsViewModel>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let spies = Spies(
            makeAbroad: .init(stubs: [
                makeAbroad(abroad ?? makeContactsViewModel())
            ]),
            makeAnotherCard: .init(stubs: [
                makeAnotherCard(anotherCard ?? makeAnotherCard())
            ]),
            makeContacts: .init(stubs: [
                makeContacts(contacts ?? makeContactsViewModel())
            ]),
            makeDetail: .init(stubs: [
                makeDetailPayment(detail)
            ]),
            makeLatest: .init(stubs: [latestPayment]),
            makeMeToMe: .init(stubs: [meToMe]),
            makeScanQR: .init(stubs: [
                scanQR ?? makeScanQRNode()
            ]),
            makeSource: .init(stubs: [
                sourcePayment ?? makeSourcePayment()
            ])
        )
        let sut = SUT(nanoServices: .init(
            makeAbroad: spies.makeAbroad.call,
            makeAnotherCard: spies.makeAnotherCard.call,
            makeContacts: spies.makeContacts.call,
            makeDetail: spies.makeDetail.call,
            makeLatest: spies.makeLatest.call,
            makeMeToMe: spies.makeMeToMe.call,
            makeScanQR: spies.makeScanQR.call,
            makeSource: spies.makeSource.call
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spies)
    }
    
    private func makeAbroad() -> ContactsViewModel {
        
        return .sampleFastContacts
    }
    
    private func makeContactsViewModel() -> ContactsViewModel {
        
        return .sampleFastContacts
    }
    
    private func makeAbroad(
        _ model: ContactsViewModel = .sampleFastContacts
    ) -> Node<ContactsViewModel> {
        
        return .init(model: model, cancellables: [])
    }
    
    private func makeContacts(
        _ model: ContactsViewModel = .sampleFastContacts
    ) -> Node<ContactsViewModel> {
        
        return .init(model: model, cancellables: [])
    }
    
    private func makeMeToMeNode(
        with model: Model = .mockWithEmptyExcept(),
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Node<PaymentsMeToMeViewModel> {
        
        return try.init(model: makeMeToMe(with: model), cancellables: [])
    }
    
    private func makeAnotherCard() -> ClosePaymentsViewModelWrapper {
        
        return makePayments()
    }
    
    private func makeAnotherCard(
        _ wrapper: ClosePaymentsViewModelWrapper? = nil
    ) -> Node<ClosePaymentsViewModelWrapper> {
        
        return makePaymentsNode(wrapper)
    }
    
    private func makeDetailPayment() -> ClosePaymentsViewModelWrapper {
        
        return makePayments()
    }
    
    private func makeDetailPayment(
        _ wrapper: ClosePaymentsViewModelWrapper? = nil
    ) -> Node<ClosePaymentsViewModelWrapper> {
        
        return makePaymentsNode(wrapper)
    }
    
    private func makeLatestPayment(
        _ wrapper: ClosePaymentsViewModelWrapper? = nil
    ) -> Node<ClosePaymentsViewModelWrapper> {
        
        return makePaymentsNode(wrapper)
    }
    
    private func makePayments(
    ) -> ClosePaymentsViewModelWrapper {
        
        return .init(model: .emptyMock, service: .c2b, scheduler: .immediate)
    }
    
    private func makePaymentsNode(
        _ model: ClosePaymentsViewModelWrapper? = nil
    ) -> Node<ClosePaymentsViewModelWrapper> {
        
        return .init(model: model ?? makePayments(), cancellables: [])
    }
    
    private func makeScanQR() -> QRModel {
        
        return .init(
            mapScanResult: { _,_ in },
            makeQRModel: { .preview(closeAction: $0) },
            scheduler: .immediate
        )
    }
    
    private func makeScanQRNode(
        _ qrModel: QRModel? = nil
    ) -> Node<QRModel> {
        
        return .init(model: qrModel ?? makeScanQR(), cancellables: [])
    }
    
    @_disfavoredOverload
    private func makeSourcePayment() -> PaymentsViewModel {
        
        return makePayments().paymentsViewModel
    }
    
    private func makeSourcePayment(
        _ model: PaymentsViewModel? = nil
    ) -> Node<PaymentsViewModel> {
        
        return .init(model: model ?? makeSourcePayment(), cancellables: [])
    }
}

// MARK: - DSL

extension Model {
    
    func addMeToMeProduct(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        products.value.append(element: .accountActiveRub, toValueOfKey: .account)
        _ = try XCTUnwrap(PaymentsMeToMeViewModel(self, mode: .demandDeposit), "Fail to add product for MeToMe (Expected PaymentsMeToMeViewModel, got nil instead).", file: file, line: line)
    }
}

private extension PaymentsTransfersPersonalTransfersNavigationComposer {
    
    func compose(
        _ buttonType: Domain.ButtonType
    ) -> Domain.Navigation? {
        
        self.compose(.buttonType(buttonType), notify: { _ in })
    }
}

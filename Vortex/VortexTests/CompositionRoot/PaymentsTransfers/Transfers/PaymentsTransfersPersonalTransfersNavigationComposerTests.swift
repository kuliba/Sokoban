//
//  PaymentsTransfersPersonalTransfersNavigationComposerTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 23.10.2024.
//

@testable import Vortex
import XCTest

final class PaymentsTransfersPersonalTransfersNavigationComposerTests: PaymentsTransfersPersonalTransfersTests {
    
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
        
        assert(navigation, .contacts(.init(abroad)))
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
        
        assert(navigation, .payments(.init(anotherCard)))
    }
    
    func test_betweenSelf_shouldCallMakeContacts() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.betweenSelf)
        
        XCTAssertEqual(spies.makeMeToMe.callCount, 1)
    }
    
    func test_betweenSelf_shouldDeliverMakeMeToMeFailureOnNil() {
        
        let (sut, _) = makeSUT(meToMe: nil)
        
        let navigation = sut.compose(.betweenSelf)
        
        assert(navigation, .makeMeToMeFailure)
    }
    
    func test_betweenSelf_shouldDeliverMeToMe() throws {
        
        let meToMe = try makeMeToMeNode()
        let (sut, _) = makeSUT(meToMe: meToMe)
        
        let navigation = sut.compose(.betweenSelf)
        
        assert(navigation, .meToMe(.init(meToMe.model)))
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
        
        assert(navigation, .contacts(.init(contacts)))
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
        
        assert(navigation, .payments(.init(detail)))
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
        
        assert(navigation, .payments(.init(source.model)))
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
        
        assert(navigation, .payments(.init(source.model)))
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
        
        assert(navigation, .payments(.init(source.model)))
    }
    
    // MARK: - latest
    
    func test_latest_shouldCallMakeLatestPayment() {
        
        let latestID: LatestPaymentData.ID = .random(in: 1...100)
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.latest(latestID)) { _ in }
        
        XCTAssertNoDiff(spies.makeLatest.payloads.map(\.0), [latestID])
    }
    
    func test_latest_shouldDeliverMakeLatestFailureOnNil() {
        
        let (sut, _) = makeSUT(latestPayment: nil)
        
        let navigation = sut.compose(.latest(.random(in: 1...100))) { _ in }
        
        assert(navigation, .makeLatestFailure)
    }
    
    func test_latest_shouldDeliverLatestPayment() throws {
        
        let latest = makeLatestPayment()
        let (sut, _) = makeSUT(latestPayment: latest)
        
        let navigation = sut.compose(.latest(.random(in: 1...100))) { _ in }
        
        assert(navigation, .payments(.init(latest.model)))
    }
    
    // MARK: - qr: result
    
    // TODO: - add tests
    
    // MARK: - qr: scan
    
    func test_scanQR_shouldDeliverScanQR() {
                
        let (sut, _) = makeSUT()
        
        let navigation = sut.compose(.scanQR) { _ in }
  
        assert(navigation, .scanQR)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersPersonalTransfersNavigationComposer
    private typealias Notify = (SUT.Domain.NotifyEvent) -> Void
    private typealias MakeAbroad = CallSpy<Notify, Node<ContactsViewModel>>
    private typealias MakeAnotherCard = CallSpy<Notify, Node<PaymentsViewModel>>
    private typealias MakeContacts = CallSpy<Notify, Node<ContactsViewModel>>
    private typealias MakeDetail = CallSpy<Notify, Node<PaymentsViewModel>>
    private typealias MakeLatest = CallSpy<(LatestPaymentData.ID, Notify), Node<PaymentsViewModel>?>
    private typealias MakeMeToMe = CallSpy<Notify, Node<PaymentsMeToMeViewModel>?>
    private typealias MakeSource = CallSpy<(Payments.Operation.Source, Notify), Node<PaymentsViewModel>>
    
    private struct Spies {
        
        let makeAbroad: MakeAbroad
        let makeAnotherCard: MakeAnotherCard
        let makeContacts: MakeContacts
        let makeDetail: MakeDetail
        let makeLatest: MakeLatest
        let makeMeToMe: MakeMeToMe
        let makeSource: MakeSource
    }
    
    private func makeSUT(
        anotherCard: PaymentsViewModel? = nil,
        abroad: ContactsViewModel? = nil,
        contacts: ContactsViewModel? = nil,
        detail: PaymentsViewModel? = nil,
        latestPayment: Node<PaymentsViewModel>? = nil,
        meToMe: Node<PaymentsMeToMeViewModel>? = nil,
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
                makeAnotherCardNode(anotherCard ?? makeAnotherCard())
            ]),
            makeContacts: .init(stubs: [
                makeContacts(contacts ?? makeContactsViewModel())
            ]),
            makeDetail: .init(stubs: [
                makeDetailPaymentNode(detail)
            ]),
            makeLatest: .init(stubs: [latestPayment]),
            makeMeToMe: .init(stubs: [meToMe]),
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
    
    private func makeAnotherCard(
        closeAction: @escaping () -> Void = {}
    ) -> PaymentsViewModel {
        
        return makePayments(closeAction: closeAction)
    }
    
    private func makeAnotherCardNode(
        _ viewModel: PaymentsViewModel? = nil
    ) -> Node<PaymentsViewModel> {
        
        return makePaymentsNode(viewModel)
    }
    
    private func makeDetailPayment(
        closeAction: @escaping () -> Void = {}
    ) -> PaymentsViewModel {
        
        return makePayments(closeAction: closeAction)
    }
        
    private func makeDetailPaymentNode(
        _ detail: PaymentsViewModel? = nil
    ) -> Node<PaymentsViewModel> {
        
        return .init(model: detail ?? makeDetailPayment(), cancellables: [])
    }
        
    private func makeLatestPayment(
        _ wrapper: PaymentsViewModel? = nil
    ) -> Node<PaymentsViewModel> {
        
        return makePaymentsNode(wrapper)
    }
    
    private func makePayments(
        closeAction: @escaping () -> Void
    ) -> PaymentsViewModel {
        
        return .init(.emptyMock, service: .c2b, closeAction: closeAction)
    }
    
    private func makePaymentsNode(
        _ model: PaymentsViewModel? = nil,
        closeAction: @escaping () -> Void = {}
    ) -> Node<PaymentsViewModel> {
        
        return .init(model: model ?? makePayments(closeAction: closeAction), cancellables: [])
    }
    
    private func makeScanQR() -> QRScannerModel {
        
        return .init(
            mapScanResult: { _,_ in },
            makeQRScanner: { QRViewModel.preview(closeAction: $0) },
            scheduler: .immediate
        )
    }
    
    private func makeScanQRNode(
        _ qrModel: QRScannerModel? = nil
    ) -> Node<QRScannerModel> {
        
        return .init(model: qrModel ?? makeScanQR(), cancellables: [])
    }
    
    @_disfavoredOverload
    private func makeSourcePayment(
        closeAction: @escaping () -> Void
    ) -> PaymentsViewModel {
        
        return makePayments(closeAction: closeAction)
    }
    
    private func makeSourcePayment(
        _ model: PaymentsViewModel? = nil,
        closeAction: @escaping () -> Void = {}
    ) -> Node<PaymentsViewModel> {
        
        return .init(model: model ?? makeSourcePayment(closeAction: closeAction), cancellables: [])
    }
}

// MARK: - DSL

extension Model {
    
    func addMeToMeProduct(
        product: ProductData? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        products.value.append(element: product ?? .accountActiveRub, toValueOfKey: product?.productType ?? .account)
        _ = try XCTUnwrap(PaymentsMeToMeViewModel(self, mode: .demandDeposit), "Fail to add product for MeToMe (Expected PaymentsMeToMeViewModel, got nil instead).", file: file, line: line)
    }
}

private extension PaymentsTransfersPersonalTransfersNavigationComposer {
    
    func compose(
        _ buttonType: Domain.ButtonType
    ) -> Domain.Navigation {
        
        self.compose(.buttonType(buttonType), notify: { _ in })
    }
}

//
//  PaymentsTransfersPersonalTransfersNavigationComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 23.10.2024.
//

enum PaymentsTransfersPersonalTransfersDomain {
    
    typealias Element = PTSectionTransfersView.ViewModel.TransfersButtonType
    
    enum Navigation {
        
        case contacts(Node<ContactsViewModel>)
        case meToMe(PaymentsMeToMeViewModel)
        case payments(Node<PaymentsViewModel>)
    }
}

struct PaymentsTransfersPersonalTransfersNavigationComposerNanoServices {
    
    let makeAbroad: MakeContactsViewModel
    let makeAnotherCard: MakeAnotherCard
    let makeContacts: MakeContactsViewModel
    let makeDetailPayment: MakeDetailPayment
    let makeMeToMe: MakeMeToMe
}

extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServices{
    
    typealias MakeAnotherCard = () -> Node<PaymentsViewModel>
    typealias MakeContactsViewModel = () -> Node<ContactsViewModel>
    typealias MakeDetailPayment = () -> Node<PaymentsViewModel>
    typealias MakeMeToMe = () -> PaymentsMeToMeViewModel?
}

final class PaymentsTransfersPersonalTransfersNavigationComposer {
    
    private let nanoServices: NanoServices
    
    init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
    
    typealias NanoServices = PaymentsTransfersPersonalTransfersNavigationComposerNanoServices
}

extension PaymentsTransfersPersonalTransfersNavigationComposer {
    
    func compose(
        _ element: Domain.Element
    ) -> Domain.Navigation? {
        
        switch element {
        case .abroad:
            return .contacts(nanoServices.makeAbroad())
            
        case .anotherCard:
            return .payments(nanoServices.makeAnotherCard())
            
        case .betweenSelf:
            return nanoServices.makeMeToMe().map { .meToMe($0) }
            
        case .byPhoneNumber:
            return .contacts(nanoServices.makeContacts())
            
        case .requisites:
            return .payments(nanoServices.makeDetailPayment())
        }
    }
    
    typealias Domain = PaymentsTransfersPersonalTransfersDomain
}

@testable import ForaBank
import XCTest

final class PaymentsTransfersPersonalTransfersNavigationComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.makeAbroad.callCount, 0)
        XCTAssertEqual(spies.makeAnotherCard.callCount, 0)
        XCTAssertEqual(spies.makeContacts.callCount, 0)
        XCTAssertEqual(spies.makeDetailPayment.callCount, 0)
        XCTAssertEqual(spies.makeMeToMe.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
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
        
        let meToMe = try makePaymentsMeToMeViewModel()
        let (sut, _) = makeSUT(meToMe: meToMe)
        
        let navigation = sut.compose(.betweenSelf)
        
        switch navigation {
        case let .meToMe(received):
            XCTAssert(meToMe === received)
            
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
    
    func test_requisites_shouldCallMakeDetailPayment() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.requisites)
        
        XCTAssertEqual(spies.makeDetailPayment.callCount, 1)
    }
    
    func test_requisites_shouldDeliverContacts() {
        
        let detailPayment = makeDetailPayment()
        let (sut, _) = makeSUT(detailPayment: detailPayment)
        
        let navigation = sut.compose(.requisites)
        
        switch navigation {
        case let .payments(received):
            XCTAssert(detailPayment === received.model)
            
        default:
            XCTFail("Expected contacts, got \(String(describing: navigation)) instead.")
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersPersonalTransfersNavigationComposer
    private typealias MakeAnotherCard = CallSpy<Void, Node<PaymentsViewModel>>
    private typealias MakeDetailPayment = CallSpy<Void, Node<PaymentsViewModel>>
    private typealias MakeAbroad = CallSpy<Void, Node<ContactsViewModel>>
    private typealias MakeContacts = CallSpy<Void, Node<ContactsViewModel>>
    private typealias MakeMeToMe = CallSpy<Void, PaymentsMeToMeViewModel?>
    
    private struct Spies {
        
        let makeAbroad: MakeAbroad
        let makeAnotherCard: MakeAnotherCard
        let makeContacts: MakeContacts
        let makeDetailPayment: MakeDetailPayment
        let makeMeToMe: MakeMeToMe
    }
    
    private func makeSUT(
        anotherCard: PaymentsViewModel? = nil,
        abroad: ContactsViewModel? = nil,
        contacts: ContactsViewModel? = nil,
        detailPayment: PaymentsViewModel? = nil,
        meToMe: PaymentsMeToMeViewModel? = nil,
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
            makeDetailPayment: .init(stubs: [
                makeDetailPayment(detailPayment)
            ]),
            makeMeToMe: .init(stubs: [meToMe])
        )
        let sut = SUT(nanoServices: .init(
            makeAbroad: spies.makeAbroad.call,
            makeAnotherCard: spies.makeAnotherCard.call,
            makeContacts: spies.makeContacts.call,
            makeDetailPayment: spies.makeDetailPayment.call,
            makeMeToMe: spies.makeMeToMe.call
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
    
    private func makePaymentsMeToMeViewModel(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> PaymentsMeToMeViewModel {
        
        let model: Model = .mockWithEmptyExcept()
        try model.addMeToMeProduct(file: file, line: line)
        
        return try XCTUnwrap(PaymentsMeToMeViewModel(model, mode: .demandDeposit), "Expected PaymentsMeToMeViewModel, got nil instead.", file: file, line: line)
    }
    
    private func makeAnotherCard() -> PaymentsViewModel {
        
        return .sample
    }
    
    private func makeAnotherCard(
        _ model: PaymentsViewModel? = nil
    ) -> Node<PaymentsViewModel> {
        
        return makePaymentsViewModelNode(model)
    }
    
    private func makeDetailPayment() -> PaymentsViewModel {
        
        return .sample
    }
    
    private func makeDetailPayment(
        _ model: PaymentsViewModel? = nil
    ) -> Node<PaymentsViewModel> {
        
        return makePaymentsViewModelNode(model)
    }
    
    private func makePaymentsViewModelNode(
        _ model: PaymentsViewModel? = nil
    ) -> Node<PaymentsViewModel> {
        
        return .init(model: model ?? makeAnotherCard(), cancellables: [])
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

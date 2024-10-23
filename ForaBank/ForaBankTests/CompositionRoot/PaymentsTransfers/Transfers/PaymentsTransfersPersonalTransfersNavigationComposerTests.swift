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
    }
}

struct PaymentsTransfersPersonalTransfersNavigationComposerNanoServices {
    
    let makeContacts: MakeContactsViewModel
    let makeMeToMe: MakeMeToMe
}

extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServices{
    
    typealias MakeContactsViewModel = () -> Node<ContactsViewModel>
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
        case .betweenSelf:
            return nanoServices.makeMeToMe().map { .meToMe($0) }
            
        case .byPhoneNumber:
            return .contacts(nanoServices.makeContacts())
            
        default:
            fatalError()
        }
    }
    
    typealias Domain = PaymentsTransfersPersonalTransfersDomain
}

@testable import ForaBank
import XCTest

final class PaymentsTransfersPersonalTransfersNavigationComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.makeContacts.callCount, 0)
        XCTAssertEqual(spies.makeMeToMe.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_betweenSelf_shouldCallMakeContacts() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.betweenSelf)
        
        XCTAssertEqual(spies.makeMeToMe.callCount, 1)
    }
    
    func test_betweenSelf_shouldDeliverNilOn___() {
        
        let (sut, _) = makeSUT()
        
        let navigation = sut.compose(.betweenSelf)
        
        switch navigation {
        case .none:
            break
            
        default:
            XCTFail("Expected nil navigation, got \(String(describing: navigation)) instead.")
        }
    }
    
    func test_betweenSelf_shouldDeliverMeToMeOn___() throws {
        
        let meToMe = try makePaymentsMeToMeViewModel()
        let (sut, _) = makeSUT(meToMe: meToMe)
        
        let navigation = sut.compose(.betweenSelf)
        
        switch navigation {
        case let .meToMe(receivedMeToMe):
            XCTAssert(meToMe === receivedMeToMe)
            
        default:
            XCTFail("Expected nil navigation, got \(String(describing: navigation)) instead.")
        }
    }
    
    func test_byPhone_shouldCallMakeContacts() {
        
        let (sut, spies) = makeSUT()
        
        _ = sut.compose(.byPhoneNumber)
        
        XCTAssertEqual(spies.makeContacts.callCount, 1)
    }
    
    func test_byPhone_shouldDeliverContacts() {
        
        let contacts = makeContactsViewModel()
        let (sut, _) = makeSUT(contacts: contacts)
        
        let navigation = sut.compose(.byPhoneNumber)
        
        switch navigation {
        case let .contacts(receivedContacts):
            XCTAssert(contacts === receivedContacts.model)
            
        default:
            XCTFail("Expected contacts, got \(String(describing: navigation)) instead.")
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersPersonalTransfersNavigationComposer
    private typealias MakeContacts = CallSpy<Void, Node<ContactsViewModel>>
    private typealias MakeMeToMe = CallSpy<Void, PaymentsMeToMeViewModel?>
    
    private struct Spies {
        
        let makeContacts: MakeContacts
        let makeMeToMe: MakeMeToMe
    }
    
    private func makeSUT(
        contacts: ContactsViewModel? = nil,
        meToMe: PaymentsMeToMeViewModel? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let spies = Spies(
            makeContacts: .init(stubs: [
                makeContactsViewModelNode(
                    contacts ?? makeContactsViewModel()
                )
            ]),
            makeMeToMe: .init(stubs: [meToMe])
        )
        let sut = SUT(nanoServices: .init(
            makeContacts: spies.makeContacts.call,
            makeMeToMe: spies.makeMeToMe.call
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spies)
    }
    
    private func makeContactsViewModel() -> ContactsViewModel {
        
        return .sampleFastContacts
    }
    
    private func makeContactsViewModelNode(
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

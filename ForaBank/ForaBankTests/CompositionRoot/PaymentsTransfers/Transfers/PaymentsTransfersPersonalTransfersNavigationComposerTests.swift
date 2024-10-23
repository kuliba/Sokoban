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
    }
}

struct PaymentsTransfersPersonalTransfersNavigationComposerNanoServices {

    let makeContacts: MakeContactsViewModel
}

extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServices{
    
    typealias MakeContactsViewModel = () -> Node<ContactsViewModel>
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
    ) -> Domain.Navigation {
        
        switch element {
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
        XCTAssertNotNil(sut)
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
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersPersonalTransfersNavigationComposer
    private typealias MakeContacts = CallSpy<Void, Node<ContactsViewModel>>
    
    private struct Spies {
        
        let makeContacts: MakeContacts
    }
    
    private func makeSUT(
        contacts: ContactsViewModel? = nil,
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
            ])
        )
        let sut = SUT(nanoServices: .init(
            makeContacts: spies.makeContacts.call
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
}

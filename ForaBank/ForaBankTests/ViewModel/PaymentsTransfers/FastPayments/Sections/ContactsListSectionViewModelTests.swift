//
//  ContactsListSectionViewModelTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 25.10.2023.
//

@testable import ForaBank
import TextFieldComponent
import XCTest

final class ContactsListSectionViewModelTests: XCTestCase {

    // MARK: - init
    
    func test_init() {
        
        let sut = makeSUT()
        
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.visible.count, 0)
        XCTAssertNil(sut.selfContact)
        XCTAssertEqual(sut.filter.value, nil)
    }
    
    func test_test_filter_containsValue() {
        
        XCTAssertContacts(filter("5"), .default)
    }
    
    func test_test_filter_filterNil() {
        
        XCTAssertContacts(filter(nil), .default)
    }

    func test_test_filter_filterEmpty() {
        
        XCTAssertContacts(filter("   "), .default)
    }

    func test_test_filter_notContainsValue() {
        
        XCTAssertContacts(filter("7"), [])
    }

    func test_test_filter_itemsEmpty() {
        
        let result = filter(
            items: [],
            "7"
        )
        
        XCTAssertContactsByStyle(result, .empty)
    }

    func test_test_filter_filterWithSpaces_containsAllValue() {
        
        XCTAssertContacts(filter("5 5"), .default)
    }
    
    func test_test_filter_filterWithSpaces_contains1Value() {
        
        XCTAssertContacts(filter("5 1"), [.phone55_11])
    }
    
    func test_test_filter_filterWithSpacesAndPlus_containsAllValue() {
        
        XCTAssertContacts(filter("+5 5"), .default)
    }
    
    func test_test_filter_filterWithSpacesAndPlus_contains1Value() {
        
        XCTAssertContacts(filter("+5 1"), [.phone55_11])
    }

    // TODO: add tests for other ContactsListSectionViewModel behaviour

    // MARK: - Helpers
    
    private func makeSUT(
        mode: ContactsSectionViewModel.Mode = .select,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ContactsListSectionViewModel {
     
        let sut = ContactsListSectionViewModel(
            .emptyMock,
            mode: mode
        )

        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func filter(
        items: [ContactsItemViewModel] = .default,
        _ filter: String?
    ) -> [ContactsItemViewModel] {
        return ContactsListSectionViewModel.reduce(
            items: items,
            filter: filter
        )
    }
    
    private func XCTAssertContacts(
        _ contacts: [ContactsItemViewModel],
        _ otherContacts: [ContactsItemViewModel]
    ) {
        XCTAssertNoDiff(contacts.map{ $0.id }, otherContacts.map{ $0.id })
    }
    
    private func XCTAssertContactsByStyle(
        _ contacts: [ContactsItemViewModel],
        _ otherContacts: [ContactsItemViewModel]
    ) {
        XCTAssertNoDiff(
            contacts.map{ ($0 as? ContactsPlaceholderItemView.ViewModel)?.style },
            otherContacts.map{ ($0 as? ContactsPlaceholderItemView.ViewModel)?.style }
        )
    }

}

extension Array where Element == ContactsItemViewModel {
    
    static let `default`: Self = [
        .phone55_11,
        .phone55_55
    ]
    
    static let empty: Self = (0..<8).map { _ in ContactsPlaceholderItemView.ViewModel(style: .person) }
}

extension ContactsItemViewModel {
    
    static let phone55_55 = ContactsPersonItemView.ViewModel(
        id: "+55 55",
        icon: .image(.checkImage),
        name: "контакт",
        phone: "+55 55",
        isBankIcon: false,
        action: {})
    
    static let phone55_11 = ContactsPersonItemView.ViewModel(
        id: "+55 11",
        icon: .image(.checkImage),
        name: "контакт",
        phone: "+55 11",
        isBankIcon: false,
        action: {})
}

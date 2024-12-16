//
//  ContactsListSectionViewModelTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 25.10.2023.
//

@testable import Vortex
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
      
    // MARK: - test filter

    func test_filterEmpty_visibleContactsNotChange() {
        
        assertContacts(defaultFiltered(by: nil), .default)
        assertContacts(defaultFiltered(by: ""), .default)
        assertContacts(defaultFiltered(by: "   "), .default)
    }

    func test_filter_notContainsValue() {
        
        assertContacts(defaultFiltered(by: "7"), [])
        assertContacts(defaultFiltered(by: "й"), [])
        assertContacts(defaultFiltered(by: "контакт1 1"), [])
    }

    func test_filter_containsValue() {
        
        assertContacts(defaultFiltered(by: "+"), .default)
        assertContacts(defaultFiltered(by: "5"), .default)
        assertContacts(defaultFiltered(by: "5 5"), .default)
        assertContacts(defaultFiltered(by: "5 1"), [.phone55_11])
        assertContacts(defaultFiltered(by: "+5 5"), .default)
        assertContacts(defaultFiltered(by: "+5 1"), [.phone55_11])
        assertContacts(defaultFiltered(by: "н"), .default)
        assertContacts(defaultFiltered(by: "кон"), .default)
        assertContacts(defaultFiltered(by: "контакт1"), [.phone55_55])
        assertContacts(defaultFiltered(by: "контакт1 "), [.phone55_55])
    }
    
    // MARK: - items is empty - check by style
    
    func test_filter_itemsEmpty() {
        
        let result = filter(items: [], "7")
        
        assertContactsByStyle(result, .empty)
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
        items: [ContactsItemViewModel],
        _ filter: String?
    ) -> [ContactsItemViewModel] {
        return ContactsListSectionViewModel.reduce(
            items: items,
            filter: filter
        )
    }
    
    private func defaultFiltered(
        by filter: String?
    ) -> [ContactsItemViewModel] {
        return ContactsListSectionViewModel.reduce(
            items: .default,
            filter: filter
        )
    }
    
    private func assertContacts(
        _ contacts: [ContactsItemViewModel],
        _ otherContacts: [ContactsItemViewModel]
    ) {
        XCTAssertNoDiff(contacts.map(\.id), otherContacts.map(\.id))
    }
    
    private func assertContactsByStyle(
        _ contacts: [ContactsItemViewModel],
        _ otherContacts: [ContactsItemViewModel]
    ) {
        XCTAssertNoDiff(
            contacts.map { ($0 as? ContactsPlaceholderItemView.ViewModel) }.map(\.?.style),
            otherContacts.map { ($0 as? ContactsPlaceholderItemView.ViewModel) }.map(\.?.style)
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
        name: "контакт1",
        phone: "+55 55",
        isBankIcon: false,
        action: {})
    
    static let phone55_11 = ContactsPersonItemView.ViewModel(
        id: "+55 11",
        icon: .image(.checkImage),
        name: "контакт2",
        phone: "+55 11",
        isBankIcon: false,
        action: {})
}

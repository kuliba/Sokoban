//
//  ContactsAgent+ContactsListTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 14.11.2023.
//

@testable import ForaBank
import XCTest
import Contacts

final class ContactsAgent_ContactsListTests: XCTestCase {
    
    // MARK: - test fetchContacts
    
    func test_fetchContacts_phoneEquals10Digits_shouldAdd7() throws {
        
        let (sut, contact, addressContact) = makeSUT(
            by: "9630000000",
            phoneFormatted: "+7 963 000-00-00"
        )
        
        let result = sut.fetchContacts([contact])
        
        assertContacts(result, [addressContact])
    }
    
    func test_fetchContacts_phoneLess10Digits_shouldNoAdd7() throws {
        
        let (sut, contact, addressContact) = makeSUT(
            by: "963000000",
            phoneFormatted: "+963 000 000"
        )
        
        let result = sut.fetchContacts([contact])
        
        assertContacts(result, [addressContact])
    }
    
    func test_fetchContacts_phoneMore10Digits_shouldNoAdd7() throws {
        
        let (sut, contact, addressContact) = makeSUT(
            by: "96300000000",
            phoneFormatted: "+963 000 000 00"
        )
        
        let result = sut.fetchContacts([contact])
        
        assertContacts(result, [addressContact])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        by phone: String,
        phoneFormatted: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ContactsAgent,
        contact: CNContact,
        equatableContact :AddressBookContact.EquatableAddressBookContact
    ) {
        
        let sut = ContactsAgent(phoneNumberFormatter: PhoneNumberKitFormater())        
        let contact = CNMutableContact()
        let phone = CNLabeledValue(
            label: CNLabelWork,
            value: CNPhoneNumber(stringValue : phone))
        contact.phoneNumbers = [phone]
        
        let addressContact: AddressBookContact.EquatableAddressBookContact = .init(
            phone: phoneFormatted,
            firstName: "",
            middleName: "",
            lastName: "",
            avatar: nil)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, contact, addressContact)
    }
}

